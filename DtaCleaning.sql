/*
Cleaning Data in SQL Queries
*/

select * 
from Portfolio..NashVileHousing
---------------------------------------
-- Standardize Date Format: 

select SaleDate 
from Portfolio..NashVileHousing;

select SaleDate, CONVERT(date, SaleDate)
from Portfolio..NashVileHousing;

update NashVileHousing
set SaleDate=CONVERT(date, SaleDate)
--as it didn't work:

Alter Table NashVileHousing
Add saleDateConverted date;

update NashVileHousing
set saleDateConverted = CONVERT(date, SaleDate);

select saleDateConverted, CONVERT(date, SaleDate)
from Portfolio..NashVileHousing;

---------------------------------------
-- Populate Property Address (is null?)

select PropertyAddress
from Portfolio..NashVileHousing

 
select PropertyAddress
from Portfolio..NashVileHousing
where PropertyAddress is null;

select *
from Portfolio..NashVileHousing
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from Portfolio..NashVileHousing a
join Portfolio..NashVileHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null;
 

 update a
 set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
 from Portfolio..NashVileHousing a
join Portfolio..NashVileHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into (Address, City, State)

select PropertyAddress
from Portfolio..NashVileHousing

select
SUBSTRING(PropertyAddress,1 , charindex(',' ,PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',' ,PropertyAddress) +1 , LEN(PropertyAddress)) as City
from Portfolio..NashVileHousing

--add the new columns
Alter Table NashVileHousing
Add PropertySplitAddress nvarchar(255);

update NashVileHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress,1 , charindex(',' ,PropertyAddress) -1)


Alter Table NashVileHousing
Add PropertySplitCity nvarchar(255);

update NashVileHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',' ,PropertyAddress) +1 , LEN(PropertyAddress)) 
 
 select *
 from Portfolio..NashVileHousing;

 --ownerAddress
 Select OwnerAddress
From Portfolio..NashVileHousing

select 
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
from Portfolio..NashVileHousing

ALTER TABLE NashVileHousing
Add OwnerSplitAddress Nvarchar(255);
Update NashVileHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashVileHousing
Add OwnerSplitCity Nvarchar(255);
Update NashVileHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE NashVileHousing
Add OwnerSplitState Nvarchar(255);
Update NashVileHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

select * 
from Portfolio..NashVileHousing
-------------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" 

select SoldAsVacant
from Portfolio..NashVileHousing

select distinct SoldAsVacant, COUNT(SoldAsVacant)
from Portfolio..NashVileHousing
group by SoldAsVacant
order by 2

select SoldAsVacant
,case when SoldAsVacant = 'Y' then 'Yse'
      when SoldAsVacant = 'N' then 'NO'
	  else SoldAsVacant
	  end
from Portfolio..NashVileHousing

Update NashVileHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
	   from Portfolio..NashVileHousing

select distinct SoldAsVacant, COUNT(SoldAsVacant)
from Portfolio..NashVileHousing
group by SoldAsVacant
order by 2 --Done
-----------------------------------------------------------------------------------------------
-- Remove Duplicates

with RowNumCTE as(
select *,
ROW_NUMBER() over(
 partition by parcelID,
              PropertyAddress,
			  SalePrice,
			  SaleDate,
			  LegalReference
			  ORDER BY
					UniqueID) as row_num
from Portfolio..NashVileHousing
)
delete 
--select *
from RowNumCTE
where row_num >1
--order by PropertyAddress

select *
from Portfolio..NashVileHousing
--------------------------------------------------------------------------------------------------------
-- Delete Unused Columns

ALTER TABLE Portfolio..NashVileHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate 