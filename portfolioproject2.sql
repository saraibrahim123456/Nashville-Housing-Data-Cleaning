select * from [Nashvile housing]
--standardize saledate
select SaleDateconverted,convert(date, saledate) from [Nashvile housing]
update [Nashvile housing]
set SaleDate = convert(date, saledate)
alter table [Nashvile housing]
add saledateconverted date;
update [Nashvile housing]
set saledateconverted = convert(date,saledate)

---Populate property address
select a.ParcelID,b.ParcelID,a.propertyaddress,b.propertyaddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from [Nashvile housing] a
join [Nashvile housing] b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null
update a
set propertyaddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from [Nashvile housing] a
join [Nashvile housing] b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

--modify Propertyaddress into indivisual columns (address,city)
select Propertyaddress from [Nashvile housing]
select
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as address
,SUBSTRING(propertyaddress,CHARINDEX(',',PropertyAddress)+1,LEN(propertyaddress)) as address
from [Nashvile housing]
alter table[Nashvile housing]
add propertysplitaddress nvarchar(255);
update [Nashvile housing]
set  propertysplitaddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) 
alter table [Nashvile housing]
add propertysplitcity nvarchar(255);
update [Nashvile housing]
set propertysplitcity=SUBSTRING(propertyaddress,CHARINDEX(',',PropertyAddress)+1,LEN(propertyaddress))

--split owneraddress 
select* --owneraddress
from [Nashvile housing]

select parsename (replace (owneraddress,',' ,'.'),3)
,parsename (replace (owneraddress,',' ,'.'),2)
,parsename (replace (owneraddress,',' ,'.'),1)
from [Nashvile housing]

alter table[Nashvile housing]
add OwnerAddresssplitstate nvarchar(255)
alter table[Nashvile housing]
add OwnerAddresssplitaddress nvarchar(255)
alter table[Nashvile housing]
add OwnerAddresssplitcity nvarchar(255)
update [Nashvile housing]
set OwnerAddresssplitcity= parsename (replace (owneraddress,',' ,'.'),2)
update [Nashvile housing]
set OwnerAddresssplitstate= parsename (replace (owneraddress,',' ,'.'),1)
update [Nashvile housing]
set OwnerAddresssplitaddress= parsename (replace (owneraddress,',' ,'.'),3)

-- change y and n to yes and no in slodasvacant
select distinct(soldasvacant),count (soldasvacant)
from [Nashvile housing]
group by SoldAsVacant
order by 2
select soldasvacant,
case when soldasvacant = 'y' then 'yes'
     when soldasvacant = 'n' then 'no'
	 else soldasvacant
	 end
	 from [Nashvile housing]
	 update [Nashvile housing]
	 set SoldAsVacant=
case when soldasvacant = 'y' then 'yes'
     when soldasvacant = 'n' then 'no'
	 else soldasvacant
	 end


	 --Remove duplicate by creating cte
	 with rownumcte as (
	 select *,
	 ROW_NUMBER()over(
	 partition by parcelid,propertyaddress,saleprice,saledate,legalreference
	 order by uniqueid) row_num
	 from [Nashvile housing])
	 delete from rownumcte
	 where row_num>1
	 ----Drop unused column
	 alter table  [Nashvile housing]
	 drop column saledate
	 select * from [Nashvile housing]
