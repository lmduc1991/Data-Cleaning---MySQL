-- chose database
use sql_cleaning;

-- create table and load infile
Drop table if exists `housing_data`;

Create table `housing_data`(
`UniqueID` varchar(50) unique,
`ParcelID` varchar(50),
`LandUse` varchar(150),
`PropertyAddress` varchar(150) default null,
`SaleDate` date default null,
`SalePrice` varchar(50) default null,
`LegalReference` varchar(150) default null,
`SoldAsVacant` varchar(50) default null,
`OwnerName` varchar(150) default null,
`OwnerAddress` varchar(150) default null,
`Acreage` varchar(50) default null,
`TaxDistrict` varchar(150) default null,
`LandValue` varchar(50) default null,
`BuildingValue` varchar(50) default null,
`TotalValue` varchar(50) default null,
`YearBuilt` varchar(50) default null,
`Bedrooms` varchar(50) default null,
`FullBath` varchar(50) default null,
`HalfBath` varchar(50));

load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Nashville Housing Data_csv.csv'
into table housing_data
FIELDS TERMINATED BY ","
ENCLOSED BY '"'
LINES TERMINATED BY "\n"
Ignore 1 rows
(UniqueID,@ParcelID,@LandUse,@PropertyAddress,@SaleDate,@SalePrice,@LegalReference,@SoldAsVacant,
@OwnerName,@OwnerAddress,@Acreage,@TaxDistrict,@LandValue,@BuildingValue,@TotalValue,@YearBuilt,
@Bedrooms,@FullBath,@HalfBath)
Set
ParcelID = nullif(@ParcelID, ''),
LandUse = nullif(@LandUse, ''),
PropertyAddress = nullif(@PropertyAddress, ''),
SaleDate = nullif(@SaleDate, ''),
SalePrice = nullif(@SalePrice, ''),
LegalReference = nullif(@LegalReference, ''),
SoldAsVacant = nullif(@SoldAsVacant, ''),
OwnerName = nullif(@OwnerName, ''),
OwnerAddress = nullif(@OwnerAddress, ''),
Acreage = nullif(@Acreage, ''),
TaxDistrict = nullif(@TaxDistrict, ''),
LandValue = nullif(@LandValue, ''),
BuildingValue = nullif(@BuildingValue, ''),
TotalValue = nullif(@TotalValue, ''),
YearBuilt = nullif(@YearBuilt, ''),
Bedrooms = nullif(@Bedrooms, ''),
FullBath = nullif(@FullBath, ''),
HalfBath = nullif(@HalfBath, 99);

-- Get the view of everything in table
Select *
From housing_data;

-- fill all null data in PropertyAddress column
Update housing_data As a
join housing_data As B
    On a.ParcelID = b.ParcelID
    And a.UniqueID <> b.UniqueID
Set a.PropertyAddress = ifnull(a.PropertyAddress,b.PropertyAddress)
where a.PropertyAddress is null;
    -- double check data
Select * 
From housing_data;

-------------------------------------------------------------------------------------------------------
-- Breaking out PropertyAddress & OwnerAddress into individual columns (Address, City, States)
    -- Breaking PropertyAddress using substring
Alter table housing_data
Add PropertyStreetAddress varchar(250) After PropertyAddress,
Add PropertyCity varchar(250) after PropertyStreetAddress;

Update housing_data
Set PropertyStreetAddress = Substring(PropertyAddress,1, Position(',' in PropertyAddress)-1),
    PropertyCity = Substring(PropertyAddress,Position(',' in PropertyAddress)+1,length(PropertyAddress));
    
    -- Breaking OwnerAddress into 3 columns (address, city, state) using Substring_index
Select substring_index(OwnerAddress,',',1) As OwnerStreetAddress,
        substring_index(substring_index(OwnerAddress,',',2),',',-1) As OwnerCity,
        substring_index(OwnerAddress,',',-1) As OwnerState
From housing_data;

Alter table housing_data
Add OwnerStreetAddress varchar(250) After OwnerAddress,
Add OwnerCity varchar(250) After OwnerStreetAddress,
Add OwnerState varchar(250) After OwnerCity;

Update housing_data
Set OwnerStreetAddress = substring_index(OwnerAddress,',',1),
    OwnerCity = substring_index(substring_index(OwnerAddress,',',2),',',-1),
    OwnerState = substring_index(OwnerAddress,',',-1);

-------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in SoldAsVacant column

Update housing_data
Set SoldAsVacant = Case
    When SoldAsVacant = 'Y' Then 'Yes'
    When SoldAsVacant = 'N' Then 'No'
    Else SoldAsVacant
End;

-------------------------------------------------------------------------------------------------------


