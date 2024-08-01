# importing libraries
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.firefox.options import Options
from currency_converter import CurrencyConverter
import pandas as pd

# creating blank dataframe to store new report
columns=['Website Name','Product Title','Price(₹)']
df=pd.DataFrame(columns=columns)

# importing old data from backend
import pandas as pd
old_df=pd.read_csv("products.csv")

# function to add new data to dataframe
def add_row(data):
    global df
    df = df._append(data, ignore_index=True)

c = CurrencyConverter()

# loading the web driver
options = Options()
options.add_argument('--headless')
driver = webdriver.Firefox(options=options)
print("Web Driver Loaded Successfully...")

# scraping of first website
i=0
driver.get(old_df['Link'][i])
title=driver.find_element(By.CLASS_NAME, "product-area__details__title.product-detail__gap-sm.h2").text
price=driver.find_element(By.CLASS_NAME, "current-price.theme-money").text
amt=float(price[3:])
# converting currency to INR
price=c.convert(amt, 'USD', 'INR')
name=old_df['Website Name'][i]
# adding scraped data to dataframe
details={'Website Name':name,'Product Title':title,'Price(₹)':round(price)}
add_row(details)
print(f"Scraping Done : {name}")
i+=1

# scraping of second website
driver.get(old_df['Link'][i])
title=driver.find_element(By.CLASS_NAME, "product-detail__title.mb-2").text
price=driver.find_element(By.CLASS_NAME, "product-price-exc-vat").text
amt=float(price[1:])
# converting currency to INR
price=c.convert(amt, 'GBP', 'INR')
name=old_df['Website Name'][i]
# adding scraped data to dataframe
details={'Website Name':name,'Product Title':title,'Price(₹)':round(price)}
add_row(details)
print(f"Scraping Done : {name}")
i+=1

# scraping of third website
driver.get(old_df['Link'][i])
title=driver.find_element(By.ID, "pdp_namebuy__1TU6P").text
price=driver.find_element(By.CLASS_NAME, "buyingoption_selling__02Pyb").text
price=price.replace(',','')
price=float(price.replace('₹',''))
name=old_df['Website Name'][i]
# adding scraped data to dataframe
details={'Website Name':name,'Product Title':title,'Price(₹)':round(price)}
add_row(details)
print(f"Scraping Done : {name}")
i+=1

# scraping of fourth website
driver.get(old_df['Link'][i])
title=driver.find_element(By.CLASS_NAME, "x-item-title__mainTitle").text
price=driver.find_element(By.CLASS_NAME, "x-price-primary").text
amt=float(price[4:])
# converting currency to INR
price=c.convert(amt, 'USD', 'INR')
name=old_df['Website Name'][i]
# adding scraped data to dataframe
details={'Website Name':name,'Product Title':title,'Price(₹)':round(price)}
add_row(details)
print(f"Scraping Done : {name}")
i+=1

# scraping of fifth website
driver.get(old_df['Link'][i])
title=driver.find_element(By.CLASS_NAME, "base").text
price=driver.find_element(By.CLASS_NAME, "price").text
amt=float(price[1:])
# converting currency to INR
price=c.convert(amt, 'GBP', 'INR')
name=old_df['Website Name'][i]
# adding scraped data to dataframe
details={'Website Name':name,'Product Title':title,'Price(₹)':round(price)}
add_row(details)
print(f"Scraping Done : {name}")
i+=1

# scraping of sixth website
driver.get(old_df['Link'][i])
title=driver.find_element(By.CLASS_NAME, "ltr-13ze6d5-Body.efhm1m90").text
price=driver.find_element(By.CLASS_NAME, "ltr-194u1uv-Heading").text
amt=float(price[1:])
# converting currency to INR
price=c.convert(amt, 'USD', 'INR')
name=old_df['Website Name'][i]
# adding scraped data to dataframe
details={'Website Name':name,'Product Title':title,'Price(₹)':round(price)}
add_row(details)
print(f"Scraping Done : {name}")
i+=1

# scraping of seventh website
driver.get(old_df['Link'][i])
title=driver.find_element(By.CLASS_NAME, "collection-product-title").text
price=driver.find_element(By.CLASS_NAME, "product-info-price").text
amt=float(price[1:])
# converting currency to INR
price=c.convert(amt, 'GBP', 'INR')
name=old_df['Website Name'][i]
# adding scraped data to dataframe
details={'Website Name':name,'Product Title':title,'Price(₹)':round(price)}
add_row(details)
print(f"Scraping Done : {name}")
i+=1

# scraping of eighth website
driver.get(old_df['Link'][i])
data=driver.find_element(By.CLASS_NAME, "detail-single-item").text
data=data.split(sep='\n')
title=data[0]
price=data[1]
amt=float(price[1:])
# converting currency to INR
price=c.convert(amt, 'USD', 'INR')
name=old_df['Website Name'][i]
# adding scraped data to dataframe
details={'Website Name':name,'Product Title':title,'Price(₹)':round(price)}
add_row(details)
print(f"Scraping Done : {name}")
i+=1

# scraping of ninth website
driver.get(old_df['Link'][i])
title=driver.find_element(By.ID, "productTitle").text
price=driver.find_element(By.CLASS_NAME, "a-price-whole").text
price=float(price.replace(',',''))
name=old_df['Website Name'][i]
# adding scraped data to dataframe
details={'Website Name':name,'Product Title':title,'Price(₹)':round(price)}
add_row(details)
print(f"Scraping Done : {name}")
i+=1

# scraping of tenth website
driver.get(old_df['Link'][i])
title=driver.find_element(By.CLASS_NAME, "VU-ZEz").text
price=driver.find_element(By.CLASS_NAME, "Nx9bqj.CxhGGd").text
price=price.replace(',','')
price=float(price.replace('₹',''))
name=old_df['Website Name'][i]
# adding scraped data to dataframe
details={'Website Name':name,'Product Title':title,'Price(₹)':round(price)}
add_row(details)
print(f"Scraping Done : {name}")
i+=1

# scraping of eleventh website
driver.get(old_df['Link'][i])
title=driver.find_element(By.CLASS_NAME, "product-product").text
price=driver.find_element(By.CLASS_NAME, "product-price").text
price=float(price[4:])
name=old_df['Website Name'][i]
# adding scraped data to dataframe
details={'Website Name':name,'Product Title':title,'Price(₹)':round(price)}
add_row(details)
print(f"Scraping Done : {name}")
i+=1

# scraping of twelfth website
driver.get(old_df['Link'][i])
title=driver.find_element(By.CLASS_NAME, "nameCls").text
price=driver.find_element(By.CLASS_NAME, "price  ").text
price=price.replace(',','')
price=float(price.replace('₹',''))
name=old_df['Website Name'][i]
# adding scraped data to dataframe
details={'Website Name':name,'Product Title':title,'Price(₹)':round(price)}
add_row(details)
print(f"Scraping Done : {name}")
i+=1

# closing the web driver
driver.close()

# printing today's report
print("\nToday's Report\n")
print(df)

# creating empty dataframe to save products to send on email
new_df = pd.DataFrame(columns=old_df.columns)
# printing the old dataframe
print("\nOld Report\n")
print(old_df[['Website Name','Product Title', 'Price(₹)']])
f=0
l=old_df['Price(₹)']
lst=df['Price(₹)']

# comparing if new price is 5% or more lesser than the old price for each element
for i in range(0, len(l)):
    if lst[i]<= l[i]-(l[i]*0.05):
        # updating the old dataframe at backend
        old_df.at[i,'Price(₹)']=lst[i]
        # saving products to send on email
        new_df = new_df._append(old_df.loc[i], ignore_index=True)
        # counting number of products to send on email
        f+=1

# printing the final list of products
print("\nList of Products to send on E-mail\n")
print(new_df)

# checking if number of products updated > 0, then update backend file also
if(f>0):
    old_df.to_csv("products.csv", index=False)

# checking if price drop products dataframe has some products, then send the email
if new_df.shape[0]>0:
    # importing libraries
    import smtplib
    from email.mime.multipart import MIMEMultipart
    from email.mime.text import MIMEText

    # defining variables
    smtp_server = "smtp.gmail.com"
    smtp_port = 587
    sender_email='error401.python@gmail.com'
    password='pfje sxlo pkrd qnpx'
    receiver_email='deepti126agarwal@gmail.com'

    # defining subject of email
    subject='Email Automation Demo'

    # converting dataframe to table 
    html_table = new_df.to_html(index=False)

    # defining the body of email and attaching the table
    body = f"""
    <html>
    <body>
        <p>Dear Recipient,</p>
        <p>I hope this email finds you well.</p>
        <p>According to today's report, {f} websites have registered a price drop of 5% or more.</p>
        <p>Below is the list of those items along with their respective prices and website name. Kindly go through it.</p>
        {html_table}
        <p>Best regards,</p>
        <p>XYZ</p>
    </body>
    </html>
    """

    # embedding all variables to email
    msg = MIMEMultipart()
    msg['From'] = sender_email
    msg['To'] = receiver_email
    msg['Subject'] = subject

    # creating defined table in body of email
    msg.attach(MIMEText(body, 'html'))

    # establishing connection
    server = smtplib.SMTP(smtp_server, smtp_port)
    server.starttls() 
    server.login(sender_email, password)
    text = msg.as_string()  
    
    # finally sending the email
    server.sendmail(sender_email, receiver_email, text) 

    # printing the success message
    print("\nEmail Status : Email sent successfully!")

    # closing the connection
    server.quit() 

# if no products to send, then printing the message
else:
    print("\nEmail Status : No products to send!")