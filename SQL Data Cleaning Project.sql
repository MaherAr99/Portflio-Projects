/* Cleaning Data in SQL Queries */

Select * from NashvilleHousing


----------------------------------------

--Standardize Date Format

Select SaleDate from NashvilleHousing

Update NashvilleHousing
Set SaleDate = CONVERT(Date,SaleDate) --this doesn't change data type. we have to use alter instead

ALTER TABLE NashvilleHousing 
ALTER COLUMN SaleDate DATE


-----------------------------------------

-- Populate Property Address data

Select * from NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress , IsNull(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
Set PropertyAddress = IsNull(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-----------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State) -- 2 ways

Select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) as City
from NashvilleHousing

Alter table NashvilleHousing
Add PropertySplitAddress nvarchar(255)

Alter table NashvilleHousing
Add PropertySplitCity nvarchar(255)

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress))

Select OwnerAddress from NashvilleHousing
 
select 
PARSENAME(Replace(OwnerAddress,',','.'),3) ,
PARSENAME(Replace(OwnerAddress,',','.'),2) ,
PARSENAME(Replace(OwnerAddress,',','.'),1) 
from NashvilleHousing

Alter table NashvilleHousing
Add OwnerSplitAddress nvarchar(255)

Alter table NashvilleHousing
Add OwnerSplitCity nvarchar(255)

Alter table NashvilleHousing
Add OwnerSplitState nvarchar(255)

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',','.'),3)

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.'),2)

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress,',','.'),1) 

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select distinct(SoldAsVacant),count(SoldAsVacant) 
from NashvilleHousing 
group by SoldAsVacant
order by 1

update NashvilleHousing 
set SoldAsVacant = 
Case when SoldAsVacant='Y' then 'Yes'
	 when SoldAsVacant='N' then 'No'
	 else SoldAsVacant
	 End

-- Remove Duplicates

With RowNumCTE as (
Select * , ROW_NUMBER() over (
partition by ParcelID,
			PropertyAddress,
			SalePrice,SaleDate,
			LegalReference
			Order by UniqueID ) row_num
from NashvilleHousing
)
--Delete from RowNumCTE where row_num > 1
Select * from RowNumCTE where row_num > 1 

-- Remove Unused Columns

Select * from NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress




