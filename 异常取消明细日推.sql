drop table temp.temp_yichang_mingxi_yiman_0414;
​create table temp.temp_yichang_mingxi_yiman_0414 as 
​select aa.*, row_number() over(order by aa.eleme_order_id) as rank 
from 
		(select a.order_date,
			    b.full_name, 
			    a.eleme_order_id,
			    a.tracking_id,
			    case when (a.tms_type=7 or (a.tms_type=0 and a.plan_carrier_id=7)) then 7--自营
			         when (a.tms_type=5 or (a.tms_type=0 and a.plan_carrier_id=5)) then 5--团队
			         when (a.tms_type =10 or (a.tms_type=0 and a.plan_carrier_id=10)) then 10--生活半径
			         when (a.tms_type=6  or (a.tms_type=0 and a.plan_carrier_id=6) or (a.tms_type=0 and a.plan_carrier_id=0)) then 6--众包
			         when (a.tms_type=9 or (a.tms_type=0 and a.plan_carrier_id=9)) then 9 -- 点我达
			    end as tms_type, --运力线
			    case when a.product_tag='SIG' then '专送'
			         when a.product_tag='KS' then '快送'
			         when a.product_tag='XT' then '选推'
			         else '其他' 
			    end as product_tag, --标品
			    a.grid_id,
			    a.grid_name,
			    a.org_id, --代理商id 
			    a.minos_org_name, --代理商名称（同步minos里面的名字）
			    a.team_id,
			    a.team_name,
			    a.restaurant_id,
			    a.restaurant_name,--餐厅名
			    a.eleme_created_at,--订单创建时间
			    a.platform_created_time,--订单支付时间
			    a.confirm_at,--商家确定时间
			    a.tms_accept_at,--运力系统接单时间
			    a.taker_arrive_rst_at,--骑手到达餐厅时间
			    a.pickup_at,--取餐时间
			    a.cancel_at,--取消时间
			    a.abnormal_at,--异常时间
			    a.abnormal_cancel_at, --异常取消时间
			    a.shipping_state,--配送状态
			    case when shipping_state=70 then 2 
                              else shipping_reason_code end AS new_shipping_reason_code , --配送状态对应原因代码
			    a.order_remark_code,--异常取消拒单原因
			    a.customer_promise_delivery_time,--用户侧准时达时间
			    a.merchant_customer_walk_distance,--商铺客户步行距离
			    a.weather_code--天气状况
	   from dm.dm_tms_apollo_waybill_wide_detail a
	   left join (
	          select eleme_city_id, full_name
	          from dim.dim_gis_city) b 
	        on a.tms_city_id=b.eleme_city_id 
          where dt=get_date(-1) 
             and a.tms_source_id=1 --饿单
             and a.is_fml=0 --非代理商城市
             and a.is_book=0 --即使单
             and (
              (a.shipping_state in (90,60) and a.shipping_reason_code in (1,2,3))
              or a.shipping_state = 70 
              or (a.shipping_state in (60,90) and a.shipping_reason_code=9 and a.order_remark_code='DELIVERY_TIMEOUT')
              )
             and a.eleme_created_at is not null       

) aa 

select order_date AS `日期`,
       full_name AS `城市`,
       eleme_order_id AS `订单ID`,
       tracking_id AS `运单ID`,
       tms_type AS `运力线`,
       product_tag AS `标品`,
       grid_id AS `网格ID`,
       grid_name AS `网格名称`,
       org_id AS `代理商ID`,
       minos_org_name AS `代理商名称`,
       team_id AS `团队ID`,
       team_name AS `团队名称`,
       restaurant_id AS `餐厅ID`,
       restaurant_name AS `餐厅名`,
       eleme_created_at AS `订单创建时间`,
       platform_created_time AS `订单支付时间`,
       confirm_at AS `商家确定时间`,
       tms_accept_at AS `运力系统接单时间`,
       taker_arrive_rst_at AS `骑手到达餐厅时间`,
       pickup_at AS `取餐时间`,
       cancel_at AS `取消时间`,
       abnormal_at AS `异常时间`,
       abnormal_cancel_at AS `异常取消时间`,
       shipping_state AS `配送状态`,
       new_shipping_reason_code AS `配送状态对应原因代码`,
       order_remark_code AS `异常取消拒单原因`,
       customer_promise_delivery_time/60 AS `用户侧准时达时间(分)`,
       merchant_customer_walk_distance/100000 AS `商铺客户步行距离（公里）`,
       weather_code AS `天气状况`
from temp.temp_yichang_mingxi_yiman_0414
where rank between 1 and 30000;

select order_date AS `日期`,
       full_name AS `城市`,
       eleme_order_id AS `订单ID`,
       tracking_id AS `运单ID`,
       tms_type AS `运力线`,
       product_tag AS `标品`,
       grid_id AS `网格ID`,
       grid_name AS `网格名称`,
       org_id AS `代理商ID`,
       minos_org_name AS `代理商名称`,
       team_id AS `团队ID`,
       team_name AS `团队名称`,
       restaurant_id AS `餐厅ID`,
       restaurant_name AS `餐厅名`,
       eleme_created_at AS `订单创建时间`,
       platform_created_time AS `订单支付时间`,
       confirm_at AS `商家确定时间`,
       tms_accept_at AS `运力系统接单时间`,
       taker_arrive_rst_at AS `骑手到达餐厅时间`,
       pickup_at AS `取餐时间`,
       cancel_at AS `取消时间`,
       abnormal_at AS `异常时间`,
       abnormal_cancel_at AS `异常取消时间`,
       shipping_state AS `配送状态`,
       new_shipping_reason_code AS `配送状态对应原因代码`,
       order_remark_code AS `异常取消拒单原因`,
       customer_promise_delivery_time/60 AS `用户侧准时达时间(分)`,
       merchant_customer_walk_distance/100000 AS `商铺客户步行距离（公里）`,
       weather_code AS `天气状况`
from temp.temp_yichang_mingxi_yiman_0414
where rank between 30001 and 60000;