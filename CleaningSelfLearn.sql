SELECT TOP (1000) [UniqueID ]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
  FROM [portfolioProject].[dbo].[NashvilleHousing]

  -- cleaning data in SQL Queries

  select * 
  from [dbo].[NashvilleHousing]

  -- standardize date format

  select saleDateConverted, CONVERT(date, saleDate)
  from [dbo].[NashvilleHousing]

  update NashvilleHousing
  set SaleDate = CONVERT(date, saleDate)

  ALTER TABLE [dbo].[NashvilleHousing]
  add SaleDateConverted Date; 

  update NashvilleHousing
  set SaleDateConverted = CONVERT(date, saleDate)

  -- populate the property address
  -- eliminating null values
  -- there are times we also have duplicate values
  -- we populate the null values that has similar data inside of it

  select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
  from [dbo].[NashvilleHousing] a
	join [dbo].[NashvilleHousing] b
		on a.ParcelID = b.ParcelID
		and a.[UniqueID ] <> b.[UniqueID ]
  where a.PropertyAddress is null

  update a
  set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
  from [dbo].[NashvilleHousing] a
	join [dbo].[NashvilleHousing] b
		on a.ParcelID = b.ParcelID
		and a.[UniqueID ] <> b.[UniqueID ]
  where a.PropertyAddress is null

  -- breaking out Address into Individual COlumns (Address, City, State)
  -- charindex function: searching for specific values

  select PropertyAddress
  from [dbo].[NashvilleHousing]

  SELECT 
   -- we can use this method to remove the comma
  SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address 
  -- we want to extract the address after the comma, so kita guna method ni
	, SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address 
  from [dbo].[NashvilleHousing]

  -- we can't seperate two values from one column without creating two other column

  ALTER TABLE [dbo].[NashvilleHousing]
  add PropertySplitAddress Nvarchar(255); 

  update NashvilleHousing
  set PropertySplitAddress =  SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

  ALTER TABLE [dbo].[NashvilleHousing]
  add PropertySpliteCity Nvarchar(255); 

  update NashvilleHousing
  set PropertySpliteCity = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

  select * 
  from [dbo].[NashvilleHousing]


   select OwnerAddress
  from [dbo].[NashvilleHousing]

  -- parseName, useful for sepecific value
  -- only useful for periods

  select
  PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,3)
  , PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,2)
  , PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,1)
  from [dbo].[NashvilleHousing]

  -- owner address

  ALTER TABLE [dbo].[NashvilleHousing]
  add OwnerSplitAddress Nvarchar(255); 

  update NashvilleHousing
  set OwnerSplitAddress =  PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,3)

  ALTER TABLE [dbo].[NashvilleHousing]
  add OwnerSpliteCity Nvarchar(255); 

  update NashvilleHousing
  set OwnerSpliteCity = PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,2)

  ALTER TABLE [dbo].[NashvilleHousing]
  add OwnersplitState Nvarchar(255); 

  update NashvilleHousing
  set OwnersplitState = PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,1)

  select * 
  from [dbo].[NashvilleHousing]

  -- change Y and N to yes and no in "SoldAsVacant" field

  select distinct(SoldAsVacant), COUNT(SoldAsVacant)
  from [dbo].[NashvilleHousing]
  Group By SoldAsVacant
  order by 2

  -- case statement

  Select SoldAsVacant
  , case when SoldAsVacant = 'Y' THEN 'Yes'
		 when SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END
  from [dbo].[NashvilleHousing]

  UPDATE NashvilleHousing 
  SET SoldAsVacant = case when SoldAsVacant = 'Y' THEN 'Yes'
		 when SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END

 -- REMOVING DUPLICATES
-- not a standard practice to delete duplicate datas
-- better make a temp table
-- Parititions our data

WITH RowNumCTE as ( 
SELECT * ,
	ROW_NUMBER() over(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by 
					UniqueID
					) row_num
from [dbo].[NashvilleHousing]
--order by ParcelID
)

select *
from RowNumCTE
where row_num > 1
order by PropertyAddress



-- deleting unused columns 

select *
from [dbo].[NashvilleHousing]

ALTER TABLE [dbo].[NashvilleHousing]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE [dbo].[NashvilleHousing]
DROP COLUMN SaleDate

-- purpose of this is to clean up data to make it more useful to us
-- more standardize data
-- summary of this project:

/*
	1. standardize the date format using CONVERT function
	2. Populated the property address 
	3. Learn the use of substring and parsename
	4. Change the Y to yes and N to No

*/