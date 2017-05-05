--早餐对比

--饿了吗
select eleme.city_name, eleme.new_open_time as eleme_open_time,eleme.bd_express,eleme.num as eleme_count, 
       meituan.city_name, meituan.new_open_time as meituan_open_time, meituan.bd_express,meituan.num as meituan_count, 
​       case when( (eleme.num-meituan.num) is not null and eleme.num is not null and meituan.num is not null) then (eleme.num-meituan.num) 
​            when (eleme.num is not null and meituan.num is null) then eleme.num 
​            when (eleme.num is null and meituan.num is not null) then (-1)* meituan.num  
       end as diff 
from (
     select a.city_name, a.new_open_time, a.bd_express ,count(distinct a.shop_id) as num
     from 
        (select distinct shop_id, shop_name, city_name, 
                case when delivery_product_id in (44,46) then 1 else 0 end as bd_express, 
                case when (is_open_recent_day=1 and substr(recent_day_open_time, 4, 1)*10+substr(recent_day_open_time,5,1)<30 )then concat(substr(recent_day_open_time, 0,2), ":00") 
                     when (is_open_recent_day=1 and substr(recent_day_open_time, 4, 1)*10+substr(recent_day_open_time,5,1)>=30 )then concat(substr(recent_day_open_time, 0,2), ":30") 
                     when is_open_recent_day=0 then 'close'
                end as new_open_time
         from dm.dm_prd_shop_wide
         where dt=get_date(-1) and city_name is not null and recent_day_open_time is not null 
               and city_id in (1,3,2,11,4,14,7,6,9,44,5,18,8,21,30,32,13,10,15,16,28,19,12,17,35,20,23,25,59,
                                     45,51,24,26,102,191,55,67,62,52,39,31,69,92,22,41,77,29,61,38,137,57,43,101,
                                     203,27,165,48,194,60,34,358,50,79,71,68,82,86,129,299,76,91,66,138,231,88,75,49,167,1564,197)
               and delivery_product_id in (44,46,58) 
        ) a
     
      group by a.city_name, a.new_open_time, a.bd_express
) eleme

--美团
full join 
(select b.city_name, b.new_open_time, c.bd_express, count(distinct b.id) as num
from(
      select distinct city_name,
         id, 
         case when substr(delivery_time, 4, 1)*10+substr(delivery_time,5,1)<30 then concat(substr(delivery_time, 0,2), ":00") 
              when substr(delivery_time, 4, 1)*10+substr(delivery_time,5,1)>=30 then concat(substr(delivery_time, 0,2), ":30") 
              else 'close'
         end as new_open_time 
      from dw.dw_ext_meituan_restaurant 
      where dt =get_date(-1) and city_name is not null 
      and city_name in (
      '上海','北京','杭州','深圳','广州','成都','武汉','南京','福州','重庆','天津','宁波',
      '苏州','温州','厦门','西安','沈阳','青岛','济南','长春','合肥','无锡','大连','昆明','南昌','常州',
      '南宁','东莞','佛山','珠海','泉州','义乌','嘉兴','金华','海口','台州','南通','石家庄','绍兴','呼和浩特',
      '扬州','兰州','烟台','徐州','湖州','芜湖','贵阳','惠州','太原','吉林','中山','镇江','三亚','潍坊','银川',
      '临沂','威海','昆山','淄博','湛江','盐城','包头','大庆','赣州','舟山','新乡','齐齐哈尔','九江','牡丹江',
      '揭阳','佳木斯','蚌埠','景德镇','延边','武夷山','广汉') 
      ) b
      inner join 
      (select restaurant_id, city_name, bd_express from dm.dm_vie_meituan_utp_sale where dt=get_date(-1) )c
      on c.city_name=b.city_name and c.restaurant_id=b.id  
group by b.city_name, b.new_open_time,c.bd_express) meituan 
on meituan.city_name=eleme.city_name and eleme.new_open_time=meituan.new_open_time and meituan.bd_express=eleme.bd_express; 

---夜宵对比

select eleme.city_name, eleme.new_open_time as eleme_close_time,eleme.bd_express,eleme.num as eleme_count, 
       meituan.city_name, meituan.new_open_time as meituan_close_time,meituan.bd_express,meituan.num as meituan_count, 
​       case when( (eleme.num-meituan.num) is not null and eleme.num is not null and meituan.num is not null) then (eleme.num-meituan.num) 
​            when (eleme.num is not null and meituan.num is null) then eleme.num 
​            when (eleme.num is null and meituan.num is not null) then (-1)* meituan.num  
​      end as diff 
from (
     select a.city_name, a.new_open_time,a.bd_express ,count(distinct a.shop_id) as num
     from 
        (select distinct shop_id, shop_name, city_name, case when delivery_product_id in (44,46) then 1 else 0 end as bd_express, ​
                  case when (is_open_recent_day=1 and substr(recent_day_close_time, -2, 1)*10+substr(recent_day_close_time,-1,1)<30 )then concat(substr(recent_day_close_time, -5,2), ":00") 
                       when (is_open_recent_day=1 and substr(recent_day_close_time, -2, 1)*10+substr(recent_day_close_time,-1,1)>=30 )then concat(substr(recent_day_close_time, -5,2), ":30") 
                       when is_open_recent_day=0 then 'close'
                  end as new_open_time
         from dm.dm_prd_shop_wide
         where dt=get_date(-1) and city_name is not null and recent_day_close_time is not null 
               and city_id in (1,3,2,11,4,14,7,6,9,44,5,18,8,21,30,32,13,10,15,16,28,19,12,17,35,20,23,25,59,
                                     45,51,24,26,102,191,55,67,62,52,39,31,69,92,22,41,77,29,61,38,137,57,43,101,
                                     203,27,165,48,194,60,34,358,50,79,71,68,82,86,129,299,76,91,66,138,231,88,75,49,167,1564,197)
               and delivery_product_id in (44,46,58) 
        ) a
     
      group by a.city_name, a.new_open_time, a.bd_express
) eleme

full join 
(select b.city_name, b.new_open_time, c.bd_express,count(distinct b.id) as num
from(
      select distinct city_name,
         id, 
         case when substr(delivery_time, -2, 1)*10+substr(delivery_time,-1,1)<30 then concat(substr(delivery_time, -5,2), ":00") 
              when substr(delivery_time, -2, 1)*10+substr(delivery_time,-1,1)>=30 then concat(substr(delivery_time, -5,2), ":30") 
              else 'close'
         end as new_open_time 
      from dw.dw_ext_meituan_restaurant 
      where dt =get_date(-1) and city_name is not null 
      and city_name in (
      '上海','北京','杭州','深圳','广州','成都','武汉','南京','福州','重庆','天津','宁波',
      '苏州','温州','厦门','西安','沈阳','青岛','济南','长春','合肥','无锡','大连','昆明','南昌','常州',
      '南宁','东莞','佛山','珠海','泉州','义乌','嘉兴','金华','海口','台州','南通','石家庄','绍兴','呼和浩特',
      '扬州','兰州','烟台','徐州','湖州','芜湖','贵阳','惠州','太原','吉林','中山','镇江','三亚','潍坊','银川',
      '临沂','威海','昆山','淄博','湛江','盐城','包头','大庆','赣州','舟山','新乡','齐齐哈尔','九江','牡丹江',
      '揭阳','佳木斯','蚌埠','景德镇','延边','武夷山','广汉') 
      ) b
      inner join 
      (select restaurant_id, city_name, bd_express from dm.dm_vie_meituan_utp_sale where dt=get_date(-1) )c
      on c.city_name=b.city_name and c.restaurant_id=b.id  
group by b.city_name, b.new_open_time,c.bd_express) meituan 
on meituan.city_name=eleme.city_name and eleme.new_open_time=meituan.new_open_time and meituan.bd_express=eleme.bd_express; 






---配送时长对比

--eleme
select eleme.*,meituan_num,meituan.meituan_avg,meituan.meituan_fenwei_25,meituan.meituan_fenwei_50,meituan.meituan_fenwei_75,meituan.meituan_fenwei_95
from 
(select e.city_name, count(distinct e.shop_id) as eleme_num,avg(e.open_hour) as eleme_avg, percentile_approx(e.open_hour,0.25) as eleme_fenwei_25 , percentile_approx(e.open_hour,0.5) as eleme_fenwei_50, percentile_approx(e.open_hour,0.75) as eleme_fenwei_75, percentile_approx(e.open_hour,0.95)  as eleme_fenwei_95
from
(select city_name, recent_day_open_minutes/60 as open_hour, shop_id
from dm.dm_prd_shop_wide
where dt=get_date(-1) and city_name is not null and recent_day_open_time is not null 
        and city_id in (1,3,2,11,4,14,7,6,9,44,5,18,8,21,30,32,13,10,15,16,28,19,12,17,35,20,23,25,59,
                                     45,51,24,26,102,191,55,67,62,52,39,31,69,92,22,41,77,29,61,38,137,57,43,101,
                                     203,27,165,48,194,60,34,358,50,79,71,68,82,86,129,299,76,91,66,138,231,88,75,49,167,1564,197) 
and recent_day_open_minutes<>0
)e
group by e.city_name) eleme 


left join 
--meituan
(select m.city_name, count(distinct m.id) as meituan_num, avg(m.end_at-m.start_at) as meituan_avg, percentile_approx(m.end_at-m.start_at,0.25) as meituan_fenwei_25, percentile_approx(m.end_at-m.start_at,0.5) as meituan_fenwei_50, percentile_approx(m.end_at-m.start_at,0.75) as meituan_fenwei_75, percentile_approx(m.end_at-m.start_at,0.95) as meituan_fenwei_95 
from (
select city_name, 
         ((substr(delivery_time,0,1)*10+substr(delivery_time,0,2))*60+(substr(delivery_time,4,1)*10+substr(delivery_time, 5,1)))/60 as start_at ,
         (( substr(delivery_time,-5,1)*10+substr(delivery_time,-4,1) )*60+(substr(delivery_time,-2,1)*10+substr(delivery_time,-1,1)))/60 as end_at,
        delivery_time, id 
from dw.dw_ext_meituan_restaurant 
where dt =get_date(-1) and city_name is not null 
and city_name in (
'上海','北京','杭州','深圳','广州','成都','武汉','南京','福州','重庆','天津','宁波',
'苏州','温州','厦门','西安','沈阳','青岛','济南','长春','合肥','无锡','大连','昆明','南昌','常州',
'南宁','东莞','佛山','珠海','泉州','义乌','嘉兴','金华','海口','台州','南通','石家庄','绍兴','呼和浩特',
'扬州','兰州','烟台','徐州','湖州','芜湖','贵阳','惠州','太原','吉林','中山','镇江','三亚','潍坊','银川',
'临沂','威海','昆山','淄博','湛江','盐城','包头','大庆','赣州','舟山','新乡','齐齐哈尔','九江','牡丹江',
'揭阳','佳木斯','蚌埠','景德镇','延边','武夷山','广汉') 
​and delivery_time <>'今日不营业' 
) m 
group by m.city_name) meituan 
on eleme.city_name=meituan.city_name; 
