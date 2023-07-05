-- Cleaning Data Using SQL

SELECT *
FROM `Housing.Toronto2022`

-- Standardize Date Format

Select saleDateConverted, CONVERT(Date,SaleDate)
From `Housing.Toronto2022`

Update `Housing.Toronto2022`
SET SaleDate = CONVERT(Date,SaleDate)

-- Populate Property Address data

Select *
From `Housing.Toronto2022` 
--Where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From `Housing.Toronto2022` a
JOIN `Housing.Toronto2022` b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From `Housing.Toronto2022` a
JOIN `Housing.Toronto2022` b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From `Housing.Toronto2022` 

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
From `Housing.Toronto2022` 

ALTER TABLE Toronto2022
Add PropertySplitAddress Nvarchar(255);

Update Toronto2022
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE Toronto2022
Add PropertySplitCity Nvarchar(255);

Update Toronto2022
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


Select *
From `Housing.Toronto2022` 

Select OwnerAddress
From From `Housing.Toronto2022` 

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From From `Housing.Toronto2022` 


ALTER TABLE Toronto2022
Add OwnerSplitAddress Nvarchar(255);

Update Toronto2022
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE Toronto2022
Add OwnerSplitCity Nvarchar(255);

Update Toronto2022
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE Toronto2022
Add OwnerSplitState Nvarchar(255);

Update Toronto2022
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

Select *
From `Housing.Toronto2022` 


-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From `Housing.Toronto2022` 
Group by SoldAsVacant
order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
When SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
From `Housing.Toronto2022` 

Update Toronto2022
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
When SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END


-- Delete Unused Columns

Select *
From `Housing.Toronto2022` 

ALTER TABLE Toronto2022 
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
