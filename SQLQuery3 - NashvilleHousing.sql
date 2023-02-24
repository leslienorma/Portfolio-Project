/*

Cleaning Data in SQL Queries

*/

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

-----------------------------------------------------------------------------

-- Standardize Date Format

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing

-----------------------------------------------------------------------------

-- Populate Property Address data

SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing
WHERE propertyAddress is NULL

SELECT h1.ParcelID, h1.PropertyAddress, h1.ParcelID, h2.PropertyAddress, ISNULL(h1.PropertyAddress, h2.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing AS h1
JOIN PortfolioProject.dbo.NashvilleHousing AS h2
	ON h1.ParcelID = h2.ParcelID
	AND h1.[UniqueID] <> h2.[UniqueID]
WHERE h1.PropertyAddress IS NULL

UPDATE h1
SET PropertyAddress = ISNULL(h1.PropertyAddress, h2.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing AS h1
JOIN PortfolioProject.dbo.NashvilleHousing AS h2
	ON h1.ParcelID = h2.ParcelID
	AND h1.[UniqueID] <> h2.[UniqueID]
WHERE h1.PropertyAddress IS NULL

-----------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing


SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM PortfolioProject.dbo.NashvilleHousing



ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

-----------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant END
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant =	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant END
FROM PortfolioProject.dbo.NashvilleHousing

-----------------------------------------------------------------------------

-- Remove Duplicates
WITH RowNumCTE AS (
SELECT *, 
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) AS row_num
FROM PortfolioProject.dbo.NashvilleHousing
--ORDER BY ParcelID
)

--DELETE
SELECT *
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress

-----------------------------------------------------------------------------

-- Delete Unused Columns


SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
