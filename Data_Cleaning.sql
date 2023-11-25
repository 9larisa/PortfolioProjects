/*
Cleaning Data in SQL Queries
*/

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
--------------------------------------------------------------------------------------------------
-- Standardize Date Format (there was no need here, but all these used as an example for the future)
SELECT SaleDateConverted, CONVERT(date, SaleDate) 
FROM PortfolioProject.dbo.NashvilleHousing


UPDATE NashvilleHousing
SET SaleDate = CONVERT(date, SaleDate)


ALTER TABLE NashvilleHousing
ADD SaleDateConverted DATE

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate)

---------------------------------------------------------------------------------------------------
-- Populate Property Address Data
SELECT *
FROM PortfolioProject..NashvilleHousing
-- where PropertyAddress IS NOT NULL
ORDER BY ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL





UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL
----------------------------------------------------------------------------------------------------
-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing


SELECT
SUBSTRING(CAST(PropertyAddress as varchar), 0, CHARINDEX(',', CAST(PropertyAddress as varchar))) as Address,
SUBSTRING(CAST(PropertyAddress as varchar), CHARINDEX(',', CAST(PropertyAddress as varchar)) +1, LEN(CAST(PropertyAddress as varchar))) as Address
FROM PortfolioProject..NashvilleHousing



ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(CAST(PropertyAddress as varchar), 0, CHARINDEX(',', CAST(PropertyAddress as varchar))) 


ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(CAST(PropertyAddress as varchar), CHARINDEX(',', CAST(PropertyAddress as varchar)) +1, LEN(CAST(PropertyAddress as varchar))) 



SELECT *
FROM PortfolioProject..NashvilleHousing









-----------------------------------
SELECT OwnerAddress
FROM PortfolioProject..NashvilleHousing


SELECT 
PARSENAME(REPLACE(CAST(OwnerAddress as varchar), ',', '.'), 3),
PARSENAME(REPLACE(CAST(OwnerAddress as varchar), ',', '.'), 2),
PARSENAME(REPLACE(CAST(OwnerAddress as varchar), ',', '.'), 1)
FROM PortfolioProject..NashvilleHousing





ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(CAST(OwnerAddress as varchar), ',', '.'), 3)

--

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(CAST(OwnerAddress as varchar), ',', '.'), 2)

--

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(CAST(OwnerAddress as varchar), ',', '.'), 1)



SELECT *
FROM PortfolioProject..NashvilleHousing
----------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2



SELECT SoldAsVacant,
    CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'NO'
        ELSE SoldAsVacant
        END
FROM PortfolioProject..NashvilleHousing



UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'NO'
        ELSE SoldAsVacant
        END




----------------------------------------------------------------------------------------------------

-- Rermove Duplicates
WITH RowNUMCTE as (
SELECT *, 
    ROW_NUMBER() OVER (
        PARTITION BY ParcelID,
                    PropertyAddress,
                    SalePrice,
                    SaleDate,
                    LegalReference
                    ORDER BY UniqueID) row_num
FROM PortfolioProject..NashvilleHousing
)
SELECT *
FROM RowNUMCTE
WHERE row_num > 1
ORDER BY PropertyAddress


----------------------------------------------------------------------------------------------------

-- Delete Unused Columns

SELECT *
FROM PortfolioProject..NashvilleHousing


ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress


ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate






