-- Viewing the data
SELECT TOP(100) *
FROM housing_project..nashville_housing;



-- Altering column data type in the table
ALTER TABLE housing_project..nashville_housing
ALTER COLUMN SaleDate DATE;

SELECT TOP(100) *
FROM housing_project..nashville_housing;



-- Populating null property address data
SELECT *
FROM housing_project..nashville_housing
WHERE PropertyAddress IS NULL
ORDER BY ParcelID;

SELECT a.[UniqueID ], b.[UniqueID ], a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM housing_project..nashville_housing a
JOIN housing_project..nashville_housing b
	ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM housing_project..nashville_housing a
JOIN housing_project..nashville_housing b
	ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;


-- Breaking address into separate, multiple columns
-- 1) Property Address

SELECT  PropertyAddress,
		SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS StreetAddress,
		SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 2, LEN(PropertyAddress)) AS City
FROM housing_project..nashville_housing;

ALTER TABLE housing_project..nashville_housing
ADD StreetAddress nvarchar(255);
UPDATE housing_project..nashville_housing
SET StreetAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1);

ALTER TABLE housing_project..nashville_housing
ADD City nvarchar(255);
UPDATE housing_project..nashville_housing
SET City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 2, LEN(PropertyAddress));


-- 2) Owner Address

SELECT  OwnerAddress,
		LEFT(OwnerAddress, CHARINDEX(',', OwnerAddress) - 1),
		SUBSTRING(OwnerAddress, CHARINDEX(',',OwnerAddress)+2, CHARINDEX(',',OwnerAddress,CHARINDEX(',',OwnerAddress)+1) - CHARINDEX(',',OwnerAddress)-2),
		RIGHT(OwnerAddress, LEN(OwnerAddress) - CHARINDEX(',',OwnerAddress,CHARINDEX(',',OwnerAddress)+1) -1)
FROM housing_project..nashville_housing

ALTER TABLE housing_project..nashville_housing
ADD OwnerStreetAddress nvarchar(255);
UPDATE housing_project..nashville_housing
SET OwnerStreetAddress = LEFT(OwnerAddress, CHARINDEX(',', OwnerAddress) - 1);

ALTER TABLE housing_project..nashville_housing
ADD OwnerCity nvarchar(255);
UPDATE housing_project..nashville_housing
SET OwnerCity = SUBSTRING(OwnerAddress, CHARINDEX(',',OwnerAddress)+2, CHARINDEX(',',OwnerAddress,CHARINDEX(',',OwnerAddress)+1) - CHARINDEX(',',OwnerAddress)-2);

ALTER TABLE housing_project..nashville_housing
ADD OwnerState nvarchar(255);
UPDATE housing_project..nashville_housing
SET OwnerState = RIGHT(OwnerAddress, LEN(OwnerAddress) - CHARINDEX(',',OwnerAddress,CHARINDEX(',',OwnerAddress)+1) -1);




-- Change Y and N in SoldAsVacant to Yes and No
SELECT DISTINCT SoldAsVacant
FROM housing_project..nashville_housing;

SELECT  SoldAsVacant,
		CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
			 WHEN SoldAsVacant = 'N' THEN 'No'
			 ELSE SoldAsVacant
			 END
FROM housing_project..nashville_housing;

UPDATE housing_project..nashville_housing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
			 WHEN SoldAsVacant = 'N' THEN 'No'
			 ELSE SoldAsVacant
			 END;



-- Removing duplicates
WITH t1 AS
(
	SELECT  *,
			ROW_NUMBER() OVER (PARTITION BY ParcelID,
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 ORDER BY UniqueID) AS row_num
	FROM housing_project..nashville_housing
)
DELETE
FROM t1
WHERE row_num > 1;
