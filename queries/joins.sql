--Выяснить, какие пары товаров покупают вместе чаще всего. 

with main_table as (SELECT DISTINCT order_id,
                                    product_id,
                                    name
                    FROM   (SELECT order_id,
                                   unnest(product_ids) as product_id
                            FROM   orders
                            WHERE  order_id not in (SELECT order_id
                                                    FROM   user_actions
                                                    WHERE  action = 'cancel_order')) t
                        LEFT JOIN products using(product_id)
                    ORDER BY order_id, name)
SELECT pair,
       count(order_id) as count_pair
FROM   (SELECT DISTINCT a.order_id,
                        case when a.name > b.name then string_to_array(concat(b.name, '+', a.name), '+')
                             else string_to_array(concat(a.name, '+', b.name), '+') end as pair
        FROM   main_table a join main_table b
                ON a.order_id = b.order_id and
                   a.name != b.name) t
GROUP BY pair
ORDER BY count_pair desc, pair
