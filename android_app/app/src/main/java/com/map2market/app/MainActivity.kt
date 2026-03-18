package com.map2market.app

import android.graphics.Color
import android.os.Bundle
import android.util.Log
import android.view.View
import android.widget.*
import androidx.appcompat.app.AppCompatActivity
import androidx.constraintlayout.widget.ConstraintLayout
import com.google.android.gms.maps.CameraUpdateFactory
import com.google.android.gms.maps.GoogleMap
import com.google.android.gms.maps.OnMapReadyCallback
import com.google.android.gms.maps.SupportMapFragment
import com.google.android.gms.maps.model.LatLng
import com.google.android.gms.maps.model.MarkerOptions
import com.google.android.gms.maps.model.PolylineOptions
import com.google.android.gms.maps.model.BitmapDescriptorFactory
import com.google.maps.android.heatmaps.Gradient
import com.google.maps.android.heatmaps.HeatmapTileProvider
import com.map2market.app.api.ApiService
import com.map2market.app.api.PredictionRequest
import kotlinx.coroutines.*
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import android.widget.ProgressBar

class MainActivity : AppCompatActivity(), OnMapReadyCallback {

    private lateinit var mMap: GoogleMap
    private lateinit var apiService: ApiService
    private var selectedLocation: LatLng? = null
    private var predictionResult: Any? = null
    private val baseUrl = "http://10.0.2.2:8000"
    private val TAG = "Map2Market"
    
    // UI Components
    private lateinit var categorySpinner: Spinner
    private lateinit var progressBar: ProgressBar
    private lateinit var resultPanel: ConstraintLayout
    private lateinit var resultText: TextView
    private lateinit var riskText: TextView

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        // Initialize Retrofit
        val retrofit = Retrofit.Builder()
            .baseUrl(baseUrl)
            .addConverterFactory(GsonConverterFactory.create())
            .build()

        apiService = retrofit.create(ApiService::class.java)

        // Setup Map
        val mapFragment = supportFragmentManager
            .findFragmentById(R.id.map) as SupportMapFragment
        mapFragment.getMapAsync(this)

        // Setup Category Spinner
        setupCategorySpinner()
    }

    private fun setupCategorySpinner() {
        categorySpinner = findViewById(R.id.categorySpinner)
        val categories = arrayOf("Cafe", "Restaurant", "Pharmacy", "Gym", "Supermarket", "Retail")
        val adapter = ArrayAdapter(this, android.R.layout.simple_spinner_item, categories)
        adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item)
        categorySpinner.adapter = adapter
    }

    override fun onMapReady(googleMap: GoogleMap) {
        mMap = googleMap
        val defaultLoc = LatLng(18.5204, 73.8567) // Pune
        mMap.moveCamera(CameraUpdateFactory.newLatLngZoom(defaultLoc, 13f))

        // Set map click listener
        mMap.setOnMapClickListener { latLng ->
            handleMapClick(latLng)
        }

        // Add heatmap layer
        addDensityHeatmap()
        
        Log.i(TAG, "Map ready - Location: $defaultLoc")
    }

    private fun handleMapClick(latLng: LatLng) {
        selectedLocation = latLng
        
        // Clear previous markers
        mMap.clear()
        
        // Add marker at selected location
        mMap.addMarker(
            MarkerOptions()
                .position(latLng)
                .title("Selected Location")
                .snippet("${latLng.latitude}, ${latLng.longitude}")
                .icon(BitmapDescriptorFactory.defaultMarkerWithHue(BitmapDescriptorFactory.HUE_BLUE))
        )

        // Perform prediction
        performPrediction(latLng)
    }

    private fun addDensityHeatmap() {
        try {
            val heatmapPoints = listOf(
                LatLng(18.5204, 73.8567),
                LatLng(18.5254, 73.8617),
                LatLng(18.5154, 73.8517),
                LatLng(18.5304, 73.8667),
                LatLng(18.5104, 73.8467),
                LatLng(18.5254, 73.8467),
                LatLng(18.5154, 73.8617),
                LatLng(18.5304, 73.8517),
                LatLng(18.5104, 73.8667)
            )

            val provider = HeatmapTileProvider.Builder()
                .data(heatmapPoints)
                .radius(60)
                .gradient(
                    Gradient(
                        intArrayOf(Color.BLUE, Color.CYAN, Color.GREEN, Color.YELLOW, Color.RED),
                        floatArrayOf(0f, 0.25f, 0.5f, 0.75f, 1f)
                    )
                )
                .build()

            mMap.addTileOverlay(android.gms.maps.model.TileOverlayOptions().tileProvider(provider))
            Log.i(TAG, "Heatmap added successfully")
        } catch (e: Exception) {
            Log.e(TAG, "Error adding heatmap: ${e.message}")
        }
    }

    private fun performPrediction(latLng: LatLng) {
        progressBar = findViewById(R.id.progressBar)
        progressBar.visibility = View.VISIBLE

        val selectedCategory = categorySpinner.selectedItem.toString()
        
        val request = PredictionRequest(
            latitude = latLng.latitude,
            longitude = latLng.longitude,
            category = selectedCategory,
            population_density = 3500.0 + kotlin.random.Random.nextDouble(-500.0, 500.0),
            avg_income = 80000.0 + kotlin.random.Random.nextDouble(-10000.0, 10000.0),
            competitor_count = kotlin.random.Random.nextInt(2, 12),
            rent_cost = 2500.0 + kotlin.random.Random.nextDouble(-500.0, 500.0),
            traffic_score = 70.0 + kotlin.random.Random.nextDouble(-20.0, 20.0),
            highway_distance = 1.5 + kotlin.random.Random.nextDouble(-0.5, 0.5)
        )

        CoroutineScope(Dispatchers.IO).launch {
            try {
                Log.i(TAG, "Sending prediction request for $selectedCategory at ${latLng.latitude}, ${latLng.longitude}")
                
                val response = apiService.predictLocation(request)
                
                withContext(Dispatchers.Main) {
                    progressBar.visibility = View.GONE
                    displayResults(response, latLng, selectedCategory)
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    progressBar.visibility = View.GONE
                    Log.e(TAG, "Prediction error: ${e.message}", e)
                    showError("Connection Error", "Unable to reach server: ${e.localizedMessage}")
                    Toast.makeText(
                        this@MainActivity,
                        "Error: ${e.localizedMessage}",
                        Toast.LENGTH_LONG
                    ).show()
                }
            }
        }
    }

    private fun displayResults(response: Any, latLng: LatLng, category: String) {
        try {
            resultPanel = findViewById(R.id.resultPanel)
            resultText = findViewById(R.id.resultText)
            riskText = findViewById(R.id.riskText)

            // Parse response data
            val successProb = when (response) {
                is Map<*, *> -> (response["success_probability"] as? Number)?.toDouble() ?: 0.5
                else -> 0.5
            } * 100

            val riskLevel = when (response) {
                is Map<*, *> -> response["risk_level"] as? String ?: "UNKNOWN"
                else -> "UNKNOWN"
            }

            val posFactors = when (response) {
                is Map<*, *> -> (response["top_positive_factors"] as? List<*>) ?: emptyList<String>()
                else -> emptyList<String>()
            }

            val recommendedLocations = when (response) {
                is Map<*, *> -> (response["recommended_locations"] as? List<*>) ?: emptyList<Map<String, Any>>()
                else -> emptyList<Map<String, Any>>()
            }

            // Update UI
            resultText.text = """
                Business Feasibility Analysis
                Category: $category
                Location: ${String.format("%.4f", latLng.latitude)}, ${String.format("%.4f", latLng.longitude)}
                
                Success Probability: ${String.format("%.1f", successProb)}%
                
                Positive Factors: ${posFactors.joinToString(", ")}
            """.trimIndent()

            riskText.text = "Risk Level: $riskLevel"
            riskText.setTextColor(
                when (riskLevel) {
                    "LOW" -> Color.GREEN
                    "MEDIUM" -> Color.parseColor("#FF9800")
                    "HIGH" -> Color.RED
                    else -> Color.GRAY
                }
            )

            resultPanel.visibility = View.VISIBLE

            // Add recommendation markers
            addRecommendationMarkers(recommendedLocations, latLng)

            Log.i(TAG, "Results displayed: Probability=$successProb%, Risk=$riskLevel")
            Toast.makeText(
                this,
                "Success Rate: ${String.format("%.0f", successProb)}% | Risk: $riskLevel",
                Toast.LENGTH_LONG
            ).show()

        } catch (e: Exception) {
            Log.e(TAG, "Error displaying results: ${e.message}", e)
            showError("Display Error", e.localizedMessage ?: "Unknown error")
        }
    }

    private fun addRecommendationMarkers(recommendations: List<Map<String, Any>>, centerPoint: LatLng) {
        try {
            recommendations.forEach { rec ->
                val lat = (rec["lat"] as? Number)?.toDouble()
                val lng = (rec["lng"] as? Number)?.toDouble()
                val score = (rec["score"] as? Number)?.toDouble() ?: 0.5

                if (lat != null && lng != null) {
                    mMap.addMarker(
                        MarkerOptions()
                            .position(LatLng(lat, lng))
                            .title("Better Zone")
                            .snippet(String.format("Score: %.2f", score))
                            .icon(BitmapDescriptorFactory.defaultMarkerWithHue(BitmapDescriptorFactory.HUE_GREEN))
                    )
                }
            }
            Log.i(TAG, "Added ${recommendations.size} recommendation markers")
        } catch (e: Exception) {
            Log.e(TAG, "Error adding recommendation markers: ${e.message}")
        }
    }

    private fun showError(title: String, message: String) {
        val alertDialog = androidx.appcompat.app.AlertDialog.Builder(this)
            .setTitle(title)
            .setMessage(message)
            .setPositiveButton("OK") { dialog, _ ->
                dialog.dismiss()
            }
            .create()
        alertDialog.show()
    }
}
