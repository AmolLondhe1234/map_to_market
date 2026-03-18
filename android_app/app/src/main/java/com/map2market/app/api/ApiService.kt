package com.map2market.app.api

import retrofit2.http.Body
import retrofit2.http.POST
import retrofit2.http.GET
import retrofit2.http.Query

data class PredictionRequest(
    val latitude: Double,
    val longitude: Double,
    val category: String,
    val population_density: Double,
    val avg_income: Double,
    val competitor_count: Int,
    val rent_cost: Double,
    val traffic_score: Double,
    val highway_distance: Double
)

data class Recommendation(
    val lat: Double,
    val lng: Double,
    val score: Double
)

data class PredictionResponse(
    val success_probability: Float,
    val risk_level: String,
    val top_positive_factors: List<String>,
    val top_negative_factors: List<String>,
    val recommended_locations: List<Recommendation>
)

data class NearbyService(
    val id: Int,
    val name: String,
    val category: String,
    val latitude: Double,
    val longitude: Double,
    val rating: Double
)

data class HealthResponse(
    val status: String,
    val timestamp: String,
    val model_loaded: Boolean,
    val features_loaded: Boolean,
    val database: String
)

data class MarketInsights(
    val category: String,
    val market_trend: String,
    val average_success_rate: Double,
    val top_factors: List<String>,
    val barriers_to_entry: List<String>
)

interface ApiService {
    @POST("/predict-location")
    suspend fun predictLocation(@Body request: PredictionRequest): Map<String, Any>

    @GET("/nearby-services")
    suspend fun getNearbyServices(
        @Query("latitude") latitude: Double,
        @Query("longitude") longitude: Double,
        @Query("radius_km") radiusKm: Double = 5.0,
        @Query("category") category: String? = null
    ): List<Map<String, Any>>

    @GET("/health")
    suspend fun healthCheck(): Map<String, Any>

    @GET("/status")
    suspend fun getStatus(): Map<String, Any>

    @GET("/discovery/insights")
    suspend fun getMarketInsights(@Query("category") category: String): Map<String, Any>

    @GET("/discovery/analytics")
    suspend fun getAnalytics(): Map<String, Any>

    @GET("/prediction-history")
    suspend fun getPredictionHistory(@Query("limit") limit: Int = 50): List<Map<String, Any>>

    @GET("/services/search")
    suspend fun searchServices(
        @Query("query") query: String,
        @Query("category") category: String? = null
    ): List<Map<String, Any>>
}
