---***Building Related***---
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

-- 1. Average Price per sqft by State: (listing_information, building_information)
SELECT 
    b.state,
    ROUND(AVG(l.price / l.sqft), 2) AS average_price_per_sqft
FROM 
    listing_information l
JOIN 
    building_information b ON l.building_id = b.building_id
GROUP BY 
    b.state
ORDER BY 
    average_price_per_sqft DESC;
	

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

-- 2. Popular Buildings for Each State (transaction amount by building) (transactions,building_informaiton)
WITH BuildingSales AS (
    SELECT 
        b.state,
        t.building_id,
        b.building_name,
        SUM(t.transaction_amount) AS total_sales
    FROM 
        transactions t
    JOIN 
        building_information b ON t.building_id = b.building_id
    WHERE 
        t.transaction_type = 'sell'
    GROUP BY 
        b.state, t.building_id, b.building_name
),
RankedBuildings AS (
    SELECT 
        bs.state,
        bs.building_id,
        bs.building_name,
        bs.total_sales,
        RANK() OVER (PARTITION BY bs.state ORDER BY bs.total_sales DESC) AS state_rank
    FROM 
        BuildingSales bs
)
SELECT 
    rb.state,
    rb.building_id,
    rb.building_name,
    rb.total_sales
FROM 
    RankedBuildings rb
WHERE 
    rb.state_rank <= 5
ORDER BY 
    rb.state, rb.state_rank, rb.total_sales DESC;

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

-- 3. Ranking of Annual Amenity Fee  (building_information, amenities)
SELECT 
    b.building_id,
    b.building_name,
    a.amenity_fee
FROM 
    building_information b
JOIN 
    amenities a ON b.building_id = a.building_id
ORDER BY 
    a.amenity_fee;


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

-- 4. Ranking of Amenity Amount for Each Building (building_information, amenities)

WITH AmenitiesCount AS (
    SELECT 
        b.building_id,
        b.building_name,
        b.state,
        (CAST(a.gym AS INTEGER) + 
         CAST(a.swimming_pool AS INTEGER) + 
         CAST(a.basketball_court AS INTEGER) + 
         CAST(a.parking AS INTEGER) + 
         CAST(a.lounge AS INTEGER)) AS total_amenities
    FROM 
        building_information b
    JOIN 
        amenities a ON b.building_id = a.building_id
),
RankedBuildings AS (
    SELECT 
        ac.state,
        ac.building_id,
        ac.building_name,
        ac.total_amenities,
        RANK() OVER (PARTITION BY ac.state ORDER BY ac.total_amenities DESC) AS state_rank
    FROM 
        AmenitiesCount ac
)
SELECT 
    rb.state,
    rb.building_id,
    rb.building_name,
    rb.total_amenities,
    rb.state_rank
FROM 
    RankedBuildings rb
ORDER BY 
    rb.state, rb.state_rank;



--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

-- 5. Ranking of Average School Rating Around Each Building (building_information, neiborhood, school)

WITH SchoolCount AS (
    SELECT 
        b.building_id,
        b.building_name,
        b.state,
        n.school AS amount_of_schools,
        AVG(s.school_rating) AS average_school_rating
    FROM 
        building_information b
    JOIN 
        neighborhood n ON b.building_id = n.building_id
    JOIN 
        school s ON b.building_id = s.building_id
    GROUP BY 
        b.building_id, b.building_name, b.state, n.school
)
SELECT 
    sc.building_id,
    sc.building_name,
    sc.state,
    sc.amount_of_schools,
    sc.average_school_rating
FROM 
    SchoolCount sc
ORDER BY 
    sc.state,
    sc.amount_of_schools DESC,
    sc.average_school_rating DESC;



--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

-- 6. Ranking of safety/ income level of each building (building_information, demographic)
WITH RankedBuildings AS (
    SELECT 
        b.building_id,
        b.building_name,
        b.state,
        d.income_level,
        d.criminal_rate_level,
        RANK() OVER (PARTITION BY b.state ORDER BY d.income_level DESC) AS income_rank,
        RANK() OVER (PARTITION BY b.state ORDER BY d.criminal_rate_level ASC) AS criminal_rank
    FROM 
        building_information b
    JOIN 
        demographic d ON b.building_id = d.building_id
)
SELECT 
    rb.building_id,
    rb.building_name,
    rb.state,
    rb.income_rank,
    rb.criminal_rank
FROM 
    RankedBuildings rb
ORDER BY 
    rb.income_rank, rb.criminal_rank;


---***customer related***---
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

-- 7. Ranking of Customer Retention Rate:(house_history, customer_information)

-- Step 1: Count the number of rental records for each customer
WITH customer_rental_count AS (
    SELECT 
        hh.customer_id,
        COUNT(*) AS rental_frequency
    FROM 
        house_history hh
    GROUP BY 
        hh.customer_id
),

-- Step 2: Rank customers by rental frequency
customer_ranking AS (
    SELECT 
        customer_id,
        rental_frequency,
        RANK() OVER (ORDER BY rental_frequency DESC) AS retention_rank
    FROM 
        customer_rental_count
)

-- Step 3: Select the top 10 customers
SELECT 
    cr.customer_id,
    ci.first_name,
	ci.last_name,
    cr.rental_frequency,
    cr.retention_rank
FROM 
    customer_ranking cr
JOIN 
    customer_information ci ON cr.customer_id = ci.customer_id
WHERE 
    cr.retention_rank <= 10
ORDER BY 
    cr.retention_rank;

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


---***Employee Related***---

-- 8. Ranking of Salespeople Performance: (customer_information,transactions,employees) 
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    SUM(t.transaction_amount) AS total_sales
FROM 
    transactions t
JOIN 
    customer_information ci ON t.customer_id = ci.customer_id
JOIN 
    employees e ON ci.employee_id = e.employee_id
GROUP BY 
    e.employee_id, e.first_name, e.last_name
ORDER BY 
    total_sales DESC;



--- *** Office Related （Finance）*** ---
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

-- 9. Annual Cost of the Office by Cost Type (operational_cost,offices)
SELECT 
    o.state,
    oc.cost_type,
    SUM(oc.cost_amount) AS total_annual_cost
FROM 
    operational_cost oc
JOIN 
    offices o ON oc.office_id = o.office_id
GROUP BY 
    o.state, oc.cost_type
ORDER BY 
    o.state, oc.cost_type;

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

-- 10: Total Cost of Each Office (operational_cost, offices)
SELECT 
    o.office_id,
    SUM(oc.cost_amount) AS total_operational_cost
FROM 
    operational_cost oc
JOIN 
    offices o ON oc.office_id = o.office_id
GROUP BY 
    o.office_id
ORDER BY 
    total_operational_cost DESC;

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

-- 11. Total Revenue of Each Office (agent_customer,transactions, employees)
SELECT 
    e.office_id,
    SUM(t.transaction_amount) AS total_revenue
FROM 
    transactions t
JOIN 
    agent_customer ac ON t.customer_id = ac.customer_id
JOIN 
    employees e ON ac.employee_id = e.employee_id
GROUP BY 
    e.office_id
ORDER BY 
    total_revenue DESC;

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

-- 12: Profit of Each Office (transactions,agent_customer,employees,operational_cost,offices)
WITH Revenue AS (
    SELECT 
        e.office_id,
        SUM(t.transaction_amount) AS total_revenue
    FROM 
        transactions t
    JOIN 
        agent_customer ac ON t.customer_id = ac.customer_id
    JOIN 
        employees e ON ac.employee_id = e.employee_id
    GROUP BY 
        e.office_id
), 
OperationalCost AS (
    SELECT 
        o.office_id,
        SUM(oc.cost_amount) AS total_operational_cost
    FROM 
        operational_cost oc
    JOIN 
        offices o ON oc.office_id = o.office_id
    GROUP BY 
        o.office_id
)
SELECT 
    r.office_id,
    r.total_revenue,
    oc.total_operational_cost,
    (r.total_revenue - oc.total_operational_cost) AS profit
FROM 
    Revenue r
JOIN 
    OperationalCost oc ON r.office_id = oc.office_id
ORDER BY 
    profit DESC;


