--Рассчитать ежедневную выручку сервиса и ежедневный прирост выручки. 
--Прирост выручки отразить в абсолютных значениях и в % относительно предыдущего дня.

SELECT date,
       round(daily_revenue, 1) as daily_revenue,
       round(coalesce(daily_revenue - lag(daily_revenue, 1) OVER (ORDER BY date), 0),
             1) as revenue_growth_abs,
       round(coalesce(round((daily_revenue - lag(daily_revenue, 1) OVER (ORDER BY date))::decimal / lag(daily_revenue, 1) OVER (ORDER BY date) * 100, 2), 0),
             1) as revenue_growth_percentage
FROM   (SELECT date(creation_time) as date,
               sum(price) as daily_revenue
        FROM   (SELECT order_id,
                       creation_time,
                       product_ids,
                       unnest(product_ids) as product_id
                FROM   orders
                WHERE  order_id not in (SELECT order_id
                                        FROM   user_actions
                                        WHERE  action = 'cancel_order')) t1
            LEFT JOIN products using(product_id)
        GROUP BY date) t2
ORDER BY date
