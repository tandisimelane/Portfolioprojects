-- cleaning data in SQL

SELECT * 
FROM Portfolioproject.dbo.NashvilleHousing

--standardize date format
SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM Portfolioproject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date; 

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

--populate property address data

SELECT *
FROM Portfolioproject.dbo.NashvilleHousing
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Portfolioproject.dbo.NashvilleHousing a
JOIN Portfolioproject.dbo.NashvilleHousing b
    ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Portfolioproject.dbo.NashvilleHousing a
JOIN Portfolioproject.dbo.NashvilleHousing b
    ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is null

--Breaking the address into individual columns(Address, City, State)

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
 ,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

FROM Portfolioproject.dbo.NashvilleHousing

--adding columns propertysplitadress and propertysplitcity

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255); 

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255); 

UPDATE NashvilleHousing
SET PropertySplitCity =  SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


SELECT * 
FROM Portfolioproject.dbo.NashvilleHousing


SELECT OwnerAddress
FROM Portfolioproject.dbo.NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',','.') ,3)
,PARSENAME(REPLACE(OwnerAddress, ',','.') ,2)
,PARSENAME(REPLACE(OwnerAddress, ',','.') ,1)
FROM Portfolioproject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255); 

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.') ,3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255); 

UPDATE NashvilleHousing
SET OwnerSplitCity =  PARSENAME(REPLACE(OwnerAddress, ',','.') ,2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255); 

UPDATE NashvilleHousing
SET OwnerSplitState =  PARSENAME(REPLACE(OwnerAddress, ',','.') ,1)

--Change y and n to yes and no in "sold as vacant" field

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'y' THEN 'Yes'
       WHEN SoldAsVacant = 'n' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM Portfolioproject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'y' THEN 'Yes'
       WHEN SoldAsVacant = 'n' THEN 'No'
	   ELSE SoldAsVacant
	   END

--Remove duplicates
WITH RowNumCTE AS(
SELECT *,
    ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
	             PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
				    UniqueID
					) row_num

FROM Portfolioproject.dbo.NashvilleHousing
--ORDER BY ParcelID
)
DELETE
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress

--Delete Unused columns


SELECT * 
FROM Portfolioproject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate

