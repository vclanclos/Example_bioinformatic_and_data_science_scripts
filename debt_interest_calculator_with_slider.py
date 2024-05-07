##Program to visualize how monthly payment amounts can change total interest paid over time

import pandas as pd
import matplotlib.pyplot as plt
import plotly.express as px
import plotly.graph_objects as go
import plotly.io as pio
import numpy as np
pio.renderers.default = 'iframe'
import ipywidgets as widgets
from ipywidgets import interact, Layout
from IPython.display import display
import chart_studio.plotly as py

# Example initial credit card balance-modify to fit balance on statement
PRINCIPAL = 4500.0  
# Annual interest rate in percentage-In this example, there is a 0% interest rate for a trial period
ANNUAL_INTEREST_RATE = 0 

# Function to calculate projected interest over time with starting values
def calculate_interest(monthly_payment):
    monthly_interest_rate = ANNUAL_INTEREST_RATE / 12 / 100
    remaining_balance = PRINCIPAL
    balance_history = []
    monthly_interest = []

  #Adds in an option for when interest-free trial period ends.
    for month in range(1, 60):
        if month >=9: #Add month in which intrest begins
            monthly_interest_rate = 27 / 12/ 100 #add new annual interest rate / 12/100. 27 is common for credit cards
        interest_paid_monthly = remaining_balance * monthly_interest_rate
        remaining_balance = max(remaining_balance - (monthly_payment - interest_paid_monthly), 0)
        balance_history.append(remaining_balance)
        monthly_interest.append(interest_paid_monthly)

    return balance_history, monthly_interest

def payment_table(monthly_payment):
    # Calculate interest, balance history, and monthly interest
    balance_history, monthly_interest = calculate_interest(monthly_payment)
    
    # Create a DataFrame for plotting
    df = pd.DataFrame({
        'Month': list(range(1, 60)),
        'Remaining_Balance': balance_history,
        'Monthly_interest': monthly_interest
    })
    # Adds a cumulative sum for total interest paid for downstream visualization
    df['Total_Interest_Paid'] = pd.Series(monthly_interest).cumsum()  
    
    return df

# Input minimum monthly payment

df = payment_table(147)
print(df)


monthly_payment_slider = widgets.FloatSlider(value=140, min=100, max=4500, step=5, description='Monthly Payment:', layout=Layout(width='500px'))


fig = px.line(df, x='Month', y=['Remaining_Balance', 'Total_Interest_Paid','Monthly_interest'], 
              title='Projected Credit Card Balance and Total Interest Paid Over 5 Years')
fig_widget = go.FigureWidget(fig)

# Add a second y-axis for 'Interest_Paid'
fig.update_layout(
    xaxis_title='Month',
    yaxis_title='Remaining Balance',
    yaxis2=dict(
        title='Total Interest Paid',
        overlaying='y',
        side='right'
    )
)

fig.update_layout(
    xaxis_title='Month',
    yaxis_title='Remaining Balance',
    yaxis3=dict(
        title='Monthly_interest',
        overlaying='y',
        side='right'
    )
)

#Adds a slider to change the monthly payment and see how the other values respond
@interact(monthly_payment=monthly_payment_slider)
def update_plot(monthly_payment):
    with fig_widget.batch_update():
        new_table = payment_table(monthly_payment)
        fig_widget.data[0].x = new_table['Month']
        fig_widget.data[0].y = new_table['Remaining_Balance']
        fig_widget.data[1].y = new_table['Total_Interest_Paid']
        fig_widget.data[2].y = new_table['Monthly_interest']

# Show the plot
display(fig_widget)
