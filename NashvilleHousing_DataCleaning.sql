/* 
Cleaning Data in SQL Queries for NashvilleHousing Table

*/

--Previewing the Data 
/****** Script for SelectTopNRows command from SSMS  ******/
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
  FROM [PortfolioProject].[dbo].[NashvilleHousing]

  -- Systemizing date format

    ALTER TABLE NashvilleHousing
  ADD SaleDate2 DATE;

   UPDATE NashvilleHousing
  SET SaleDate2 = CONVERT(Date, saledate)


   Select SaleDate2, CONVERT(Date, Saledate)
  From PortfolioProject.dbo.NashvilleHousing
  -----------------------------------------------------------------------------------------------------------------------------
   -- Populate Property Address data

  Select *
  From PortfolioProject.DBO.NashvilleHousing
  --where PropertyAddress is null
  order by ParcelID

    Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
  From PortfolioProject.DBO.NashvilleHousing a
  JOIN PortfolioProject.DBO.NashvilleHousing b
    ON a.parcelID = b.parcelid
	AND A.[UniqueID ] <> b.[UniqueID ]
	Where a.PropertyAddress is null

	UPDATE a
	SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
	  From PortfolioProject.DBO.NashvilleHousing a
  JOIN PortfolioProject.DBO.NashvilleHousing b
    ON a.parcelID = b.parcelid
	AND A.[UniqueID ] <> b.[UniqueID ]

	--------------------------------------------------------------------------------------------------------------------------
		--Breaking out Address into Individual Columns (Address, City, State)

	  Select *
  From PortfolioProject.DBO.NashvilleHousing
  --where PropertyAddress is null
  --order by ParcelID

  	  Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as Address
  From PortfolioProject.DBO.NashvilleHousing

-- Creating new columns Separating City from address
   UPDATE NashvilleHousing
  SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

  ALTER TABLE NashvilleHousing
  ADD PropertySplitAddress Nvarchar(255);


   UPDATE NashvilleHousing
  SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))

  ALTER TABLE NashvilleHousing
  ADD PropertySplitCity Nvarchar(255);


  Select *
    From PortfolioProject.DBO.NashvilleHousing

	---

	  Select OwnerAddress
    From PortfolioProject.DBO.NashvilleHousing

	Select ParseName (Replace(OwnerAddress, ',', '.'),3)
	,ParseName (Replace(OwnerAddress, ',', '.'),2)
	,ParseName (Replace(OwnerAddress, ',', '.'),1)
	From PortfolioProject.dbo.NashvilleHousing

---- Creating tables
	ALTER TABLE NashvilleHousing
  ADD OwnerSplitAddress Nvarchar(255);

   UPDATE NashvilleHousing
  SET OwnerSplitAddress = ParseName (Replace(OwnerAddress, ',', '.'),3)

  ALTER TABLE NashvilleHousing
  ADD OwnerSplitCity Nvarchar(255);

   UPDATE NashvilleHousing
  SET OwnerSplitCity = ParseName (Replace(OwnerAddress, ',', '.'),2)

  ALTER TABLE NashvilleHousing
  ADD OwnerSplitState Nvarchar(255);

   UPDATE NashvilleHousing
  SET OwnerSplitState = ParseName (Replace(OwnerAddress, ',', '.'),1)

    Select *
    From PortfolioProject.DBO.NashvilleHousing

	---------------------------------------------------------------------------------------------------------------------

	-- Change Y and N to Yes and No in "Sold as Vacant" field

	Select Distinct(SoldAsVacant), Count(SoldAsVacant)
	 From PortfolioProject.DBO.NashvilleHousing
	 Group by SoldAsVacant
	 Order by 2


	 Select SoldAsVacant
	 , CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
	  From PortfolioProject.DBO.NashvilleHousing

	  UPDATE NashvilleHousing
	  SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END;
	   ----------------------------------------------------------------------------------------------------------------------
	   -- Remove Duplicates
	   
	   WITH RowNumCTE AS(
	   Select *,
	   Row_NUMBER() OVER ( 
	   PARTITION BY ParcelID,
	                PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					ORDER BY 
					 UniqueID
					 ) row_num
	   	  From PortfolioProject.DBO.NashvilleHousing
		  --Order by ParcelID
		  )
		 Select *
		  From RowNumCTE
		  Where row_num > 1
		 Order BY PropertyAddress
		 ----------------------------------------------------------------------------------------------------------------

		 --DELETE Unused Columns

		 Select *
    From PortfolioProject.DBO.NashvilleHousing

	ALTER TABLE PortfolioProject.DBO.NashvilleHousing
	DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress;

	ALTER TABLE PortfolioProject.DBO.NashvilleHousing
	DROP COLUMN SaleDate
	---------------------------------------------------------------------------------------------------------

	-- Renaming Tables
EXEC sp_RENAME 'Nashvillehousing.SaleDate2' , 'SaleDate'