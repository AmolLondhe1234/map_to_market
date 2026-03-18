import pandas as pd
import numpy as np
import joblib
import os
import logging
from sklearn.model_selection import train_test_split, cross_val_score, StratifiedKFold
from sklearn.ensemble import RandomForestClassifier, GradientBoostingClassifier
from sklearn.preprocessing import StandardScaler
from sklearn.metrics import (
    accuracy_score, precision_score, recall_score, f1_score,
    confusion_matrix, classification_report, roc_auc_score, roc_curve
)
from xgboost import XGBClassifier
import warnings

warnings.filterwarnings('ignore')
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def load_or_generate_data():
    """Load training data or generate if not exists."""
    data_path = 'data/osm_enriched_business_data.csv'
    
    if os.path.exists(data_path):
        logger.info(f"Loading data from {data_path}")
        df = pd.read_csv(data_path)
    else:
        logger.info("Generating synthetic training data...")
        from featurizer import generate_training_set_from_osm
        df = generate_training_set_from_osm(num_points=300, use_synthetic=True)
    
    return df

def prepare_features(df):
    """Prepare features for modeling."""
    # Drop non-numeric columns
    X = df.drop(['success_target', 'income_level', 'density_level'], axis=1, errors='ignore')
    X = X.select_dtypes(include=[np.number])
    y = df['success_target']
    
    # Handle missing values
    X = X.fillna(X.mean())
    
    feature_names = list(X.columns)
    logger.info(f"Using {len(feature_names)} features for modeling")
    
    return X, y, feature_names

def train_and_evaluate_models(X_train, X_test, y_train, y_test):
    """Train multiple models and evaluate performance."""
    models = {}
    results = {}
    
    logger.info("Training models...")
    
    # Random Forest
    logger.info("Training Random Forest...")
    rf_model = RandomForestClassifier(
        n_estimators=150,
        max_depth=12,
        min_samples_split=5,
        min_samples_leaf=2,
        random_state=42,
        n_jobs=-1,
        class_weight='balanced'
    )
    rf_model.fit(X_train, y_train)
    rf_preds = rf_model.predict(X_test)
    rf_proba = rf_model.predict_proba(X_test)[:, 1]
    
    results['RandomForest'] = {
        'accuracy': accuracy_score(y_test, rf_preds),
        'precision': precision_score(y_test, rf_preds, zero_division=0),
        'recall': recall_score(y_test, rf_preds, zero_division=0),
        'f1': f1_score(y_test, rf_preds, zero_division=0),
        'roc_auc': roc_auc_score(y_test, rf_proba),
    }
    models['RandomForest'] = rf_model
    
    # XGBoost
    logger.info("Training XGBoost...")
    xgb_model = XGBClassifier(
        n_estimators=200,
        max_depth=8,
        learning_rate=0.1,
        subsample=0.8,
        colsample_bytree=0.8,
        random_state=42,
        eval_metric='logloss',
        use_label_encoder=False,
        scale_pos_weight=1,
        n_jobs=-1
    )
    xgb_model.fit(X_train, y_train)
    xgb_preds = xgb_model.predict(X_test)
    xgb_proba = xgb_model.predict_proba(X_test)[:, 1]
    
    results['XGBoost'] = {
        'accuracy': accuracy_score(y_test, xgb_preds),
        'precision': precision_score(y_test, xgb_preds, zero_division=0),
        'recall': recall_score(y_test, xgb_preds, zero_division=0),
        'f1': f1_score(y_test, xgb_preds, zero_division=0),
        'roc_auc': roc_auc_score(y_test, xgb_proba),
    }
    models['XGBoost'] = xgb_model
    
    # Gradient Boosting
    logger.info("Training Gradient Boosting...")
    gb_model = GradientBoostingClassifier(
        n_estimators=150,
        max_depth=6,
        learning_rate=0.1,
        subsample=0.8,
        random_state=42
    )
    gb_model.fit(X_train, y_train)
    gb_preds = gb_model.predict(X_test)
    gb_proba = gb_model.predict_proba(X_test)[:, 1]
    
    results['GradientBoosting'] = {
        'accuracy': accuracy_score(y_test, gb_preds),
        'precision': precision_score(y_test, gb_preds, zero_division=0),
        'recall': recall_score(y_test, gb_preds, zero_division=0),
        'f1': f1_score(y_test, gb_preds, zero_division=0),
        'roc_auc': roc_auc_score(y_test, gb_proba),
    }
    models['GradientBoosting'] = gb_model
    
    return models, results

def select_best_model(models, results):
    """Select the best model based on F1 score."""
    best_model_name = max(results, key=lambda x: results[x]['f1'])
    best_model = models[best_model_name]
    logger.info(f"Best model: {best_model_name}")
    return best_model_name, best_model

def train_model():
    """Main training pipeline."""
    try:
        # Load data
        df = load_or_generate_data()
        logger.info(f"Data shape: {df.shape}")
        logger.info(f"Class distribution: {df['success_target'].value_counts().to_dict()}")
        
        # Prepare features
        X, y, feature_names = prepare_features(df)
        
        # Split data
        X_train, X_test, y_train, y_test = train_test_split(
            X, y, test_size=0.2, random_state=42, stratify=y
        )
        logger.info(f"Training set: {len(X_train)}, Test set: {len(X_test)}")
        
        # Train models
        models, results = train_and_evaluate_models(X_train, X_test, y_train, y_test)
        
        # Print evaluation results
        logger.info("\n" + "="*60)
        logger.info("Model Evaluation Results")
        logger.info("="*60)
        for model_name, metrics in results.items():
            logger.info(f"\n{model_name}:")
            for metric, value in metrics.items():
                logger.info(f"  {metric}: {value:.4f}")
        
        # Select and save best model
        best_name, best_model = select_best_model(models, results)
        
        os.makedirs('models', exist_ok=True)
        
        # Save best model
        model_path = 'models/business_model.pkl'
        joblib.dump(best_model, model_path)
        logger.info(f"Best model saved to {model_path}")
        
        # Save feature names
        features_path = 'models/feature_names.pkl'
        joblib.dump(feature_names, features_path)
        logger.info(f"Feature names saved to {features_path}")
        
        # Save all models for ensemble
        ensemble_path = 'models/ensemble_models.pkl'
        joblib.dump(models, ensemble_path)
        logger.info(f"All models saved to {ensemble_path}")
        
        # Save results
        results_path = 'models/training_results.pkl'
        joblib.dump(results, results_path)
        logger.info(f"Training results saved to {results_path}")
        
        logger.info("\nTraining completed successfully!")
        
    except Exception as e:
        logger.error(f"Training failed: {str(e)}", exc_info=True)
        raise

if __name__ == "__main__":
    train_model()
