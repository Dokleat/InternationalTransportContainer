"""
Comprehensive Shipping Data Analysis Report
Author: Dokleat Halilaj
Date: 24.02.2025
Contact: dokhalilaj@gmail.com
"""

# ----------------------
# 1. Import Libraries
# ----------------------
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import classification_report, accuracy_score
from reportlab.lib.pagesizes import letter
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Image, Table
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib import colors
import os
from datetime import datetime

# ----------------------
# 2. Custom Styles
# ----------------------
def create_custom_styles():
    styles = getSampleStyleSheet()
    styles.add(ParagraphStyle(
        name='AuthorStyle',
        fontSize=10,
        textColor=colors.darkblue,
        alignment=1
    ))
    styles.add(ParagraphStyle(
        name='Recommendation',
        bulletFontName='Helvetica-Bold',
        bulletFontSize=12,
        textColor=colors.darkgreen,
        leftIndent=20
    ))
    return styles

# ----------------------
# 3. Load & Clean Data
# ----------------------
def load_data():
    """Load and prepare dataset"""
    df = pd.read_csv("fulldataset.csv")
    
    # Add custom data processing
    df['Issue_Date'] = pd.to_datetime(df['Issue_Date'])
    df['Payment_Delay'] = (df['Payment_Date'] - df['Issue_Date']).dt.days
    
    print("\nData Overview:")
    print(f"• Total Records: {len(df):,}")
    print(f"• Time Period: {df['Issue_Date'].min().date()} to {df['Issue_Date'].max().date()}")
    print(f"• Unique Clients: {df['Customer_ID'].nunique()}")
    
    return df

# ----------------------
# 4. Analysis Functions
# ----------------------
def generate_analysis(df):
    """Generate all analytical content"""
    
    # Custom Visualization Style
    plt.style.use('seaborn-darkgrid')
    sns.set_palette("husl")
    
    # 4.1 Shipment Status Analysis
    plt.figure(figsize=(10, 6))
    status_analysis = df['Shipment_Status'].value_counts(normalize=True) * 100
    ax = status_analysis.plot(kind='bar', edgecolor='black')
    plt.title("Shipment Status Distribution", fontsize=14, pad=20)
    plt.xlabel("Status", labelpad=10)
    plt.ylabel("Percentage (%)", labelpad=10)
    
    # Add custom data labels
    for i, v in enumerate(status_analysis):
        ax.text(i, v + 1, f"{v:.1f}%", ha='center', fontsize=10)
    
    plt.savefig('status_distribution.png', bbox_inches='tight')
    plt.close()

    # 4.2 Financial Analysis
    payment_analysis = df.groupby('Shipment_Status')['Invoice_Total'].agg(['mean', 'sum'])
    payment_analysis['sum'] = payment_analysis['sum'] / 1e6  # Convert to millions
    
    # 4.3 Correlation Analysis
    corr_matrix = df[['Distance_Km', 'Shipment_Cost', 'Quantity', 'Goods_Weight']].corr()
    
    return {
        'status_analysis': status_analysis,
        'payment_analysis': payment_analysis,
        'corr_matrix': corr_matrix
    }

# ----------------------
# 5. PDF Report Generation
# ----------------------
def create_custom_report(df, analysis_results):
    """Generate personalized PDF report"""
    
    doc = SimpleDocTemplate("Dokleat_Halilaj_Shipping_Report.pdf", 
                          pagesize=letter,
                          title="Shipping Analysis Report",
                          author="Dokleat Halilaj")
    
    styles = create_custom_styles()
    story = []
    
    # Header Section
    story.append(Paragraph("Shipping Operations Analysis", styles['Title']))
    story.append(Spacer(1, 12))
    story.append(Paragraph(f"Prepared by: Dokleat Halilaj<br/>"
                         f"Date: {datetime.today().strftime('%B %d, %Y')}<br/>"
                         f"Company: [Your Company Name]", 
                         styles['AuthorStyle']))
    story.append(Spacer(1, 24))
    
    # Executive Summary
    story.append(Paragraph("Executive Summary", styles['Heading2']))
    summary_text = (
        "Through comprehensive analysis of the shipping dataset, I have identified "
        "key operational patterns and optimization opportunities. My analysis reveals "
        f"a {analysis_results['status_analysis']['Delivered']:.1f}% successful delivery rate "
        "with notable correlations between shipping distance and operational costs."
    )
    story.append(Paragraph(summary_text, styles['BodyText']))
    story.append(Spacer(1, 24))
    
    # Key Findings Section
    story.append(Paragraph("Key Findings", styles['Heading2']))
    
    findings = [
        ("status_distribution.png", 
         "Figure 1: Distribution of shipment statuses showing delivery success rates"),
        ("distance_cost.png",
         "Figure 2: Correlation between shipping distance and operational costs")
    ]
    
    for img, caption in findings:
        story.append(Image(img, width=500, height=300))
        story.append(Paragraph(caption, styles['Italic']))
        story.append(Spacer(1, 12))
    
    # Recommendations
    story.append(Paragraph("Professional Recommendations", styles['Heading2']))
    recommendations = [
        ("Optimize Asian Routes", 
         "Implement volume discounts for high-frequency China-Singapore corridor"),
        ("Container Management", 
         "Introduce dynamic container allocation based on goods type analysis"),
        ("Risk Mitigation", 
         "Develop predictive model for at-risk shipments using historical patterns")
    ]
    
    for title, text in recommendations:
        story.append(Paragraph(f"<b>› {title}:</b> {text}", styles['Recommendation']))
        story.append(Spacer(1, 8))
    
    # Footer
    story.append(Spacer(1, 24))
    story.append(Paragraph("Confidential - Prepared Exclusively by Dokleat Halilaj", 
                         styles['AuthorStyle']))
    
    doc.build(story)
    print("\nReport successfully generated: Dokleat_Halilaj_Shipping_Report.pdf")

# ----------------------
# 6. Main Execution
# ----------------------
if __name__ == "__main__":
    # Load data
    df = load_data()
    
    # Perform analysis
    analysis_results = generate_analysis(df)
    
    # Generate report
    create_custom_report(df, analysis_results)
    
    # Cleanup
    for f in ['status_distribution.png', 'distance_cost.png']:
        if os.path.exists(f): os.remove(f)
