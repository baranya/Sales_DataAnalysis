/* Insights related to canceled orders-
 * 1) The shipping charge for canceled orders gradually decreases from the beginning of the year to the end.
 * 2) Some regions contribute more to return-related shipping costs, which could indicate logistics inefficiencies or product dissatisfaction in those areas.
 * 3) After analyzing the dataset, "Sofa" emerges as the product with the highest canceled order shipping costs. 
 *    This indicates that a significant number of customers return sofas, leading to increased logistics expenses.
 * 4) Return rate is higher for promotional products.
 *    Customers might be impulse-buying due to discounts and then returning items.
 * Suggestion- 
 * 1) Investigate cities/regions with high return-related shipping costs to optimize return policies or logistics.
 * 2) Offer discounts for in-store returns to reduce shipping costs.
 * 3) Product images of Sofa and descriptions might not fully match customer expectations.
 */ 

/*Month on Month spending on canceled order shipping*/
WITH MonthlyTotals AS (
    SELECT 
        strftime('%Y-%m', TransactionDate) AS Month,
        COUNT(*) AS TotalTransactions,  
        SUM(CASE WHEN Returned = 'Yes' THEN 1 ELSE 0 END) AS ReturnedTransactions,
        SUM(ShippingCost) AS MonthlyTotalShipping
    FROM cleaned_final_fixed_assessment_data
    GROUP BY Month
),
GrandTotal AS (
    SELECT SUM(MonthlyTotalShipping) AS OverallTotalShipping FROM MonthlyTotals
)
SELECT 
    mt.Month,
    mt.TotalTransactions,
    mt.ReturnedTransactions,
    ROUND((mt.ReturnedTransactions * 100.0 / mt.TotalTransactions), 2) AS ReturnRatePercentage,
    mt.MonthlyTotalShipping,
    ROUND((mt.MonthlyTotalShipping * 100.0 / gt.OverallTotalShipping), 2) AS ShippingCostPercentage
FROM MonthlyTotals mt
JOIN GrandTotal gt
WHERE mt.Month IS NOT NULL
ORDER BY mt.Month DESC;

/*Product with highest canceled order shipping*/
SELECT 
    ProductName,
    SUM(ShippingCost) AS TotalShippingCost
FROM cleaned_final_fixed_assessment_data cffad
WHERE ProductName IS NOT 'Unknown'
GROUP BY ProductName
ORDER BY TotalShippingCost DESC;

/*Month-on-Month Spending on Canceled Order Shipping (by City, Region)*/
SELECT 
    strftime('%Y-%m', TransactionDate) AS Month,
    Region,
    City,
    SUM(ShippingCost) AS TotalShippingCost
FROM cleaned_final_fixed_assessment_data cffad  
WHERE Returned = 'Yes' and Month is not null and Region IS NOT 'Unknown'
GROUP BY Month, Region, City
ORDER BY Month DESC, TotalShippingCost DESC;

/*Returned rate for Promotional offer*/
SELECT 
    IsPromotional,
    COUNT(*) AS TransactionsCount,
    SUM(CASE WHEN Returned = 'Yes' THEN 1 ELSE 0 END) AS ReturnedTransactions,
    ROUND((SUM(CASE WHEN Returned = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 2) AS ReturnRate
FROM cleaned_final_fixed_assessment_data cffad 
GROUP BY IsPromotional;



/* Insights related to highest selling product, Age-group, Payment method, delivery time-
 * 1) Online stores sell more high-value items (Laptops, Sofas, and Electronics), while In-store sales are driven by low-value, high-volume products (Clothing, Accessories).
 * 2) Female customers purchase more T-Shirt & Apparel, while Male customers dominate Electronics & Furniture sales.
 * 3) Certain regions show strong product-category dominance, like South India preferring tech products more.
 * 4) Apple mobile is the highest selling product in all region.
 * 5) Customers aged above 47 spend the most, followed by age groups 31-38 and 39-46. 18-23 and below 17 age groups contribute the least to total revenue.
 * 6) Customers prefer digital transaction more than cash.
 * 7) West India has the fastest delivery times, while North & East India face delays.
 */

/*Highest-Selling Product by Store Type (by Gender, Region)*/
SELECT 
    StoreType,
    CustomerGender,
    Region,
    ProductName,
    SUM(Quantity) AS TotalSold
FROM cleaned_final_fixed_assessment_data cffad 
WHERE StoreType IS NOT 'Unknown' and CustomerGender IS NOT 'Unknown' and Region IS NOT 'Unknown' and ProductName IS NOT 'Unknown'
GROUP BY StoreType, CustomerGender, Region, ProductName
ORDER BY TotalSold DESC;

/*Which Age Group Spends the Most on Shopping? (With Age Segmentation)*/
SELECT  
    CASE 
        WHEN CustomerAge < 18 THEN 'Below 17'
        WHEN CustomerAge BETWEEN 18 AND 23 THEN '18-23'
        WHEN CustomerAge BETWEEN 24 AND 30 THEN '24-30'
        WHEN CustomerAge BETWEEN 31 AND 38 THEN '31-38'
        WHEN CustomerAge BETWEEN 39 AND 46 THEN '39-46'
        ELSE 'Above 47'
    END AS AgeRange,
    COUNT(*) AS NumberOfTransactions,
    SUM(TransactionAmount) AS TotalSpent,
    ROUND(AVG(TransactionAmount)/(SELECT COUNT(DISTINCT strftime('%Y-%m', TransactionDate))
                                    FROM cleaned_final_fixed_assessment_data),2) AS AvgAmtPerTransPerMonth
FROM cleaned_final_fixed_assessment_data cffad 
GROUP BY AgeRange
ORDER BY TotalSpent DESC;

/*Average Delivery Time by Region*/
SELECT 
    Region, 
    StoreType, 
    AVG(DeliveryTimeDays) AS AvgDeliveryTime
FROM cleaned_final_fixed_assessment_data cffad 
WHERE Region IS NOT 'Unknown' and StoreType = 'Online'
GROUP BY Region, StoreType
ORDER BY AvgDeliveryTime;


/*Most common payment method used*/
SELECT 
    PaymentMethod,
    COUNT(*) AS UsageCount, 
    SUM(TransactionAmount) AS TotalSpent
FROM cleaned_final_fixed_assessment_data cffad 
WHERE PaymentMethod IS NOT 'Unknown'
GROUP BY PaymentMethod
ORDER BY UsageCount DESC;




