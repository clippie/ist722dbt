with stg_orders as (
    select * from {{ source('northwind','Orders')}}
),

stg_order_details as (
    select * from {{ source('northwind','Order_Details')}}
)

select
    o.orderid,
    {{ dbt_utils.generate_surrogate_key(['o.customerid']) }} as customerkey,
    {{ dbt_utils.generate_surrogate_key(['o.employeeid']) }} as employeekey,
    replace(to_date(o.orderdate)::varchar,'-','')::int as orderdatekey,
    {{ dbt_utils.generate_surrogate_key(['od.productid']) }} as productkey,
    od.quantity,
    od.quantity * od.unitprice as extendedpriceamount,
    od.quantity * od.unitprice * od.discount as discountamount,
    (od.quantity * od.unitprice) - (od.quantity * od.unitprice * od.discount) as soldamount
from stg_orders o
    join stg_order_details od on o.orderid = od.orderid