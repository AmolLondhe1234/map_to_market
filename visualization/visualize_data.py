import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import os

def generate_visualizations():
    # Load data
    if not os.path.exists('data/business_data.csv'):
        print("Data not found. Run training first.")
        return
        
    df = pd.read_csv('data/business_data.csv')
    
    # Heatmap of Business Potential (Success Probability proxy)
    plt.figure(figsize=(10, 8))
    # We'll use success_target as a proxy for heatmap intensity
    heatmap_data = df.pivot_table(index='latitude', columns='longitude', values='success_target')
    sns.heatmap(df.corr(), annot=True, cmap='coolwarm')
    plt.title('Feature Correlation Map')
    
    os.makedirs('visualization', exist_ok=True)
    plt.savefig('visualization/feature_correlation.png')
    
    # Success Probability Distribution
    plt.figure(figsize=(10, 6))
    df['avg_income'].hist(bins=30)
    plt.title('Income Distribution')
    plt.savefig('visualization/income_dist.png')
    
    print("Visualizations saved to /visualization folder.")

if __name__ == "__main__":
    generate_visualizations()
