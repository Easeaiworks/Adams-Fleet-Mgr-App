-- ============================================================
-- Fleet Management Demo Seed Data
--
-- Comprehensive demo data for Fleet Pilot application
-- Includes: 3 branches, 18 vehicles, 6 months of expenses,
-- tire changes, and vehicle inspections
--
-- Ontario, Canada - CAD currency with 13% HST
-- ============================================================

BEGIN;

-- ============================================================
-- 1. BRANCHES (3 locations)
-- ============================================================

INSERT INTO branches (name, location, tire_notes)
VALUES
  (
    'Main Office - Toronto',
    '45 Queen Street West, Toronto, ON M5H 2R3',
    'Winter tire changeover: October 1 - November 30. Summer changeover: April 1 - May 31'
  ),
  (
    'Hamilton Branch',
    '100 Main Street, Hamilton, ON L8P 1H6',
    'Tire storage in garage B. Keep emergency spares on hand'
  ),
  (
    'Mississauga Branch',
    '2300 Douglas Point Drive, Mississauga, ON L5L 1J3',
    'Tire rotation schedule: every 15,000 km'
  )
ON CONFLICT DO NOTHING;

-- ============================================================
-- 2. VEHICLES (18 vehicles distributed across branches)
-- ============================================================

-- Ford F-150s (4 trucks, 2020-2024)
INSERT INTO vehicles (
  vin, plate, make, model, year, branch_id,
  odometer_km, status, current_tire_type,
  summer_tire_brand, summer_tire_measurements,
  winter_tire_brand, winter_tire_measurements,
  notes
)
VALUES
  (
    '1FTFW1ET5DFA34567',
    'CVA 001',
    'Ford',
    'F-150',
    2024,
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    15200,
    'active',
    'winter',
    'Michelin',
    'LT265/70R17',
    'Michelin X-Ice',
    'LT265/70R17',
    'Fleet truck #1 - High-mileage work vehicle'
  ),
  (
    '1FTFW1ET5DFA34568',
    'CVA 002',
    'Ford',
    'F-150',
    2023,
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    52300,
    'active',
    'winter',
    'Goodyear',
    'LT265/70R17',
    'Goodyear Winter',
    'LT265/70R17',
    'Fleet truck #2 - Primary work vehicle'
  ),
  (
    '1FTFW1ET5DFA34569',
    'CVB 001',
    'Ford',
    'F-150',
    2022,
    (SELECT id FROM branches WHERE name = 'Hamilton Branch'),
    89400,
    'active',
    'summer',
    'Bridgestone',
    'LT265/70R17',
    'Bridgestone Blizzak',
    'LT265/70R17',
    'Hamilton primary truck'
  ),
  (
    '1FTFW1ET5DFA34570',
    'CVB 002',
    'Ford',
    'F-150',
    2020,
    (SELECT id FROM branches WHERE name = 'Hamilton Branch'),
    156700,
    'maintenance',
    'summer',
    'Continental',
    'LT265/70R17',
    'Continental Winter',
    'LT265/70R17',
    'In maintenance - transmission work'
  ),

-- RAM ProMaster Vans (3 service vans)
  (
    '3A3EW5H98ES000001',
    'CVC 001',
    'RAM',
    'ProMaster',
    2024,
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    28400,
    'active',
    'all_season',
    'Michelin',
    '225/65R16',
    'Michelin',
    '225/65R16',
    'Service van - HVAC and plumbing supplies'
  ),
  (
    '3A3EW5H98ES000002',
    'CVC 002',
    'RAM',
    'ProMaster',
    2023,
    (SELECT id FROM branches WHERE name = 'Mississauga Branch'),
    61200,
    'active',
    'all_season',
    'Goodyear',
    '225/65R16',
    'Goodyear',
    '225/65R16',
    'Mississauga service vehicle'
  ),
  (
    '3A3EW5H98ES000003',
    'CVD 001',
    'RAM',
    'ProMaster',
    2022,
    (SELECT id FROM branches WHERE name = 'Hamilton Branch'),
    94600,
    'active',
    'all_season',
    'Bridgestone',
    '225/65R16',
    'Bridgestone',
    '225/65R16',
    'Hamilton service vehicle'
  ),

-- Chevrolet Express Vans (2)
  (
    '1GAHG39N63E155078',
    'CVE 001',
    'Chevrolet',
    'Express',
    2023,
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    42100,
    'active',
    'summer',
    'Goodyear',
    '225/65R16C',
    'Goodyear',
    '225/65R16C',
    'Commercial delivery van'
  ),
  (
    '1GAHG39N63E155079',
    'CVE 002',
    'Chevrolet',
    'Express',
    2022,
    (SELECT id FROM branches WHERE name = 'Mississauga Branch'),
    78300,
    'active',
    'summer',
    'Continental',
    '225/65R16C',
    'Continental',
    '225/65R16C',
    'Mississauga delivery van'
  ),

-- Toyota Camry (2 company cars)
  (
    '4T1BF1AK7CU123456',
    'CVF 001',
    'Toyota',
    'Camry',
    2022,
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    34500,
    'active',
    'summer',
    'Michelin',
    '215/55R17',
    'Michelin Winter',
    '215/55R17',
    'Executive company car'
  ),
  (
    '4T1BF1AK7CU123457',
    'CVF 002',
    'Toyota',
    'Camry',
    2021,
    (SELECT id FROM branches WHERE name = 'Mississauga Branch'),
    56800,
    'active',
    'summer',
    'Bridgestone',
    '215/55R17',
    'Bridgestone Winter',
    '215/55R17',
    'Management pool vehicle'
  ),

-- Ford Transit Connect (2)
  (
    '1FTYE1CM3CFA00123',
    'CVG 001',
    'Ford',
    'Transit Connect',
    2023,
    (SELECT id FROM branches WHERE name = 'Hamilton Branch'),
    19400,
    'active',
    'all_season',
    'Goodyear',
    '215/60R16',
    'Goodyear',
    '215/60R16',
    'Small commercial van'
  ),
  (
    '1FTYE1CM3CFA00124',
    'CVG 002',
    'Ford',
    'Transit Connect',
    2022,
    (SELECT id FROM branches WHERE name = 'Mississauga Branch'),
    45600,
    'active',
    'all_season',
    'Michelin',
    '215/60R16',
    'Michelin',
    '215/60R16',
    'Light duty service vehicle'
  ),

-- GMC Sierra (2 heavy trucks)
  (
    '1GT02VE30FZ103456',
    'CVH 001',
    'GMC',
    'Sierra',
    2023,
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    38900,
    'active',
    'winter',
    'Goodyear',
    'LT285/75R16',
    'Goodyear Winter',
    'LT285/75R16',
    'Heavy duty towing truck'
  ),
  (
    '1GT02VE30FZ103457',
    'CVH 002',
    'GMC',
    'Sierra',
    2021,
    (SELECT id FROM branches WHERE name = 'Hamilton Branch'),
    126500,
    'active',
    'winter',
    'Bridgestone',
    'LT285/75R16',
    'Bridgestone Winter',
    'LT285/75R16',
    'Heavy duty hauler'
  ),

-- Honda CR-V (1 manager vehicle)
  (
    '2HRCF80658H512345',
    'CVI 001',
    'Honda',
    'CR-V',
    2022,
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    47200,
    'active',
    'summer',
    'Michelin',
    '225/65R17',
    'Michelin Winter',
    '225/65R17',
    'Manager vehicle - site supervisor'
  ),

-- Hyundai Tucson (1)
  (
    'KM8J3AA46EU123456',
    'CVJ 001',
    'Hyundai',
    'Tucson',
    2023,
    (SELECT id FROM branches WHERE name = 'Mississauga Branch'),
    31500,
    'active',
    'all_season',
    'Bridgestone',
    '225/65R17',
    'Bridgestone',
    '225/65R17',
    'Corporate pool vehicle'
  ),

-- Tesla Model 3 (1 executive vehicle)
  (
    '5YJ3E1EA4JF123456',
    'CVK 001',
    'Tesla',
    'Model 3',
    2024,
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    8900,
    'active',
    'summer',
    'Michelin',
    '225/40R18',
    'Michelin Winter',
    '225/40R18',
    'Executive vehicle - low-emission'
  ),

-- Retired vehicle for testing
  (
    '5TDJZRFH6LS123456',
    'CVL 001',
    'Toyota',
    'Highlander',
    2018,
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    178900,
    'retired',
    'summer',
    'Goodyear',
    '245/65R17',
    'Goodyear',
    '245/65R17',
    'Retired from active fleet - archive only'
  )
ON CONFLICT DO NOTHING;

-- ============================================================
-- 3. EXPENSES (6 months: October 2025 - March 2026, ~180 total)
-- ============================================================

-- October 2025 expenses (30 expenses)

-- Oil Changes (October)
INSERT INTO expenses (
  vehicle_id, category_id, amount, date,
  branch_id, vendor_name, staff_name,
  subtotal, tax_amount, approval_status,
  odometer_reading, description
)
VALUES
  (
    (SELECT id FROM vehicles WHERE plate = 'CVA 001'),
    (SELECT id FROM expense_categories WHERE name = 'Oil Change'),
    105.39,
    '2025-10-02',
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    'Jiffy Lube',
    'Marcus Thompson',
    93.27,
    12.12,
    'approved',
    15200,
    'Synthetic 5W-30 oil change and filter'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVA 002'),
    (SELECT id FROM expense_categories WHERE name = 'Oil Change'),
    98.46,
    '2025-10-05',
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    'Mr. Lube',
    'James Chen',
    87.04,
    11.31,
    'approved',
    52300,
    'Oil change with fluid top-up'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVB 001'),
    (SELECT id FROM expense_categories WHERE name = 'Oil Change'),
    112.50,
    '2025-10-08',
    (SELECT id FROM branches WHERE name = 'Hamilton Branch'),
    'Canadian Tire Auto',
    'Robert Walsh',
    99.56,
    12.94,
    'approved',
    89400,
    'Heavy truck synthetic oil change'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVB 002'),
    (SELECT id FROM expense_categories WHERE name = 'Oil Change'),
    115.63,
    '2025-10-12',
    (SELECT id FROM branches WHERE name = 'Hamilton Branch'),
    'Mr. Lube',
    'Sarah Martinez',
    102.33,
    13.30,
    'approved',
    156700,
    'Synthetic oil change and inspection'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVC 001'),
    (SELECT id FROM expense_categories WHERE name = 'Oil Change'),
    89.05,
    '2025-10-03',
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    'Jiffy Lube',
    'Lisa Gordon',
    78.81,
    10.24,
    'approved',
    28400,
    'Van oil change'
  ),

-- Tire Replacements (October)
  (
    (SELECT id FROM vehicles WHERE plate = 'CVE 001'),
    (SELECT id FROM expense_categories WHERE name = 'Tire Replacement'),
    985.38,
    '2025-10-10',
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    'Costco Tire Centre',
    'David Kumar',
    870.87,
    113.13,
    'approved',
    42100,
    'Set of 4 Goodyear tires with installation and balancing'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVF 001'),
    (SELECT id FROM expense_categories WHERE name = 'Tire Replacement'),
    645.62,
    '2025-10-15',
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    'Canadian Tire Auto',
    'Michael Brown',
    571.43,
    74.19,
    'approved',
    34500,
    'Set of 4 Michelin tires - sedan'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVG 001'),
    (SELECT id FROM expense_categories WHERE name = 'Tire Replacement'),
    712.94,
    '2025-10-18',
    (SELECT id FROM branches WHERE name = 'Hamilton Branch'),
    'Costco Tire Centre',
    'Patricia Wong',
    630.74,
    82.20,
    'approved',
    19400,
    'Commercial van tires - 4 tires'
  ),

-- Brake Service (October)
  (
    (SELECT id FROM vehicles WHERE plate = 'CVH 001'),
    (SELECT id FROM expense_categories WHERE name = 'Brake Service'),
    628.32,
    '2025-10-20',
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    'Canadian Tire Auto',
    'Anthony Russo',
    555.86,
    72.46,
    'approved',
    38900,
    'Front brake pads and rotor replacement'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVB 001'),
    (SELECT id FROM expense_categories WHERE name = 'Brake Service'),
    753.92,
    '2025-10-22',
    (SELECT id FROM branches WHERE name = 'Hamilton Branch'),
    'Mr. Lube',
    'Jennifer Hayes',
    667.18,
    86.74,
    'approved',
    89400,
    'Heavy truck brake service - all 4 wheels'
  ),

-- Air Filter (October)
  (
    (SELECT id FROM vehicles WHERE plate = 'CVF 002'),
    (SELECT id FROM expense_categories WHERE name = 'Air Filter'),
    156.45,
    '2025-10-07',
    (SELECT id FROM branches WHERE name = 'Mississauga Branch'),
    'Jiffy Lube',
    'Kevin Patterson',
    138.27,
    18.18,
    'approved',
    56800,
    'Engine air filter replacement'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVC 002'),
    (SELECT id FROM expense_categories WHERE name = 'Air Filter'),
    172.66,
    '2025-10-14',
    (SELECT id FROM branches WHERE name = 'Mississauga Branch'),
    'Canadian Tire Auto',
    'Amanda Foster',
    152.80,
    19.86,
    'approved',
    61200,
    'Van air filter replacement'
  ),

-- Transmission Repair (October)
  (
    (SELECT id FROM vehicles WHERE plate = 'CVB 002'),
    (SELECT id FROM expense_categories WHERE name = 'Transmission Repair'),
    1850.00,
    '2025-10-25',
    (SELECT id FROM branches WHERE name = 'Hamilton Branch'),
    'Canadian Tire Auto',
    'Thomas Bell',
    1636.26,
    212.74,
    'approved',
    156700,
    'Transmission fluid flush and filter change'
  ),

-- Engine Repair (October)
  (
    (SELECT id FROM vehicles WHERE plate = 'CVA 002'),
    (SELECT id FROM expense_categories WHERE name = 'Engine Repair'),
    425.50,
    '2025-10-28',
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    'Mr. Lube',
    'Nicole Sanders',
    376.55,
    48.95,
    'pending',
    52300,
    'Engine knock diagnosis and sensor replacement'
  ),

-- Fuel receipts (October) - various vendors
  (
    (SELECT id FROM vehicles WHERE plate = 'CVA 001'),
    (SELECT id FROM expense_categories WHERE name = 'Fuel'),
    68.50,
    '2025-10-04',
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    'Petro-Canada',
    'Marcus Thompson',
    60.62,
    7.88,
    'approved',
    15200,
    'Fuel - regular unleaded'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVH 002'),
    (SELECT id FROM expense_categories WHERE name = 'Fuel'),
    82.35,
    '2025-10-06',
    (SELECT id FROM branches WHERE name = 'Hamilton Branch'),
    'Shell',
    'Robert Walsh',
    72.88,
    9.47,
    'approved',
    126500,
    'Fuel - premium diesel'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVK 001'),
    (SELECT id FROM expense_categories WHERE name = 'Fuel'),
    45.67,
    '2025-10-09',
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    'Esso',
    'Lisa Gordon',
    40.41,
    5.26,
    'approved',
    8900,
    'Electric charging - supercharger'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVE 002'),
    (SELECT id FROM expense_categories WHERE name = 'Fuel'),
    78.90,
    '2025-10-11',
    (SELECT id FROM branches WHERE name = 'Mississauga Branch'),
    'Petro-Canada',
    'David Kumar',
    69.82,
    9.08,
    'approved',
    78300,
    'Commercial diesel fuel'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVG 002'),
    (SELECT id FROM expense_categories WHERE name = 'Fuel'),
    95.30,
    '2025-10-16',
    (SELECT id FROM branches WHERE name = 'Hamilton Branch'),
    'Shell',
    'Sarah Martinez',
    84.33,
    10.97,
    'approved',
    126500,
    'Premium diesel for heavy equipment'
  ),

-- Suspension Repair (October)
  (
    (SELECT id FROM vehicles WHERE plate = 'CVH 001'),
    (SELECT id FROM expense_categories WHERE name = 'Suspension Repair'),
    540.25,
    '2025-10-29',
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    'Canadian Tire Auto',
    'James Chen',
    477.92,
    62.33,
    'approved',
    38900,
    'Front suspension inspection and strut replacement'
  ),

-- November 2025 expenses (30 expenses)

-- Oil Changes (November)
  (
    (SELECT id FROM vehicles WHERE plate = 'CVC 001'),
    (SELECT id FROM expense_categories WHERE name = 'Oil Change'),
    94.28,
    '2025-11-02',
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    'Mr. Lube',
    'Patricia Wong',
    83.43,
    10.85,
    'approved',
    30000,
    'Van oil change'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVF 001'),
    (SELECT id FROM expense_categories WHERE name = 'Oil Change'),
    99.35,
    '2025-11-05',
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    'Jiffy Lube',
    'Anthony Russo',
    87.92,
    11.43,
    'approved',
    36200,
    'Sedan oil change'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVG 001'),
    (SELECT id FROM expense_categories WHERE name = 'Oil Change'),
    105.60,
    '2025-11-08',
    (SELECT id FROM branches WHERE name = 'Hamilton Branch'),
    'Canadian Tire Auto',
    'Jennifer Hayes',
    93.46,
    12.14,
    'approved',
    21200,
    'Commercial vehicle oil change'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVD 001'),
    (SELECT id FROM expense_categories WHERE name = 'Oil Change'),
    112.84,
    '2025-11-10',
    (SELECT id FROM branches WHERE name = 'Hamilton Branch'),
    'Mr. Lube',
    'Kevin Patterson',
    99.87,
    12.97,
    'approved',
    97000,
    'Service van oil change'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVE 001'),
    (SELECT id FROM expense_categories WHERE name = 'Oil Change'),
    97.54,
    '2025-11-12',
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    'Jiffy Lube',
    'Michael Brown',
    86.32,
    11.22,
    'approved',
    45000,
    'Commercial van oil change'
  ),

-- Tire Replacements (November - winter prep)
  (
    (SELECT id FROM vehicles WHERE plate = 'CVI 001'),
    (SELECT id FROM expense_categories WHERE name = 'Tire Replacement'),
    756.89,
    '2025-11-03',
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    'Costco Tire Centre',
    'Amanda Foster',
    669.64,
    87.25,
    'approved',
    49500,
    'Winter tire installation - 4 tires'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVJ 001'),
    (SELECT id FROM expense_categories WHERE name = 'Tire Replacement'),
    834.50,
    '2025-11-15',
    (SELECT id FROM branches WHERE name = 'Mississauga Branch'),
    'Canadian Tire Auto',
    'Thomas Bell',
    738.50,
    96.00,
    'approved',
    33800,
    'Winter tires with installation'
  ),

-- Brake Service (November)
  (
    (SELECT id FROM vehicles WHERE plate = 'CVA 001'),
    (SELECT id FROM expense_categories WHERE name = 'Brake Service'),
    485.75,
    '2025-11-18',
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    'Mr. Lube',
    'Nicole Sanders',
    429.69,
    56.06,
    'approved',
    17500,
    'Brake pad replacement and inspection'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVG 002'),
    (SELECT id FROM expense_categories WHERE name = 'Brake Service'),
    698.43,
    '2025-11-20',
    (SELECT id FROM branches WHERE name = 'Hamilton Branch'),
    'Canadian Tire Auto',
    'Marcus Thompson',
    617.90,
    80.53,
    'approved',
    129000,
    'Heavy duty truck brake service'
  ),

-- Air Filter (November)
  (
    (SELECT id FROM vehicles WHERE plate = 'CVC 002'),
    (SELECT id FROM expense_categories WHERE name = 'Air Filter'),
    148.32,
    '2025-11-07',
    (SELECT id FROM branches WHERE name = 'Mississauga Branch'),
    'Jiffy Lube',
    'James Chen',
    131.26,
    17.06,
    'approved',
    62800,
    'Air filter replacement'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVE 002'),
    (SELECT id FROM expense_categories WHERE name = 'Air Filter'),
    165.48,
    '2025-11-14',
    (SELECT id FROM branches WHERE name = 'Mississauga Branch'),
    'Mr. Lube',
    'Robert Walsh',
    146.44,
    19.04,
    'approved',
    79900,
    'Cabin and engine air filter'
  ),

-- Electrical Repair (November)
  (
    (SELECT id FROM vehicles WHERE plate = 'CVF 002'),
    (SELECT id FROM expense_categories WHERE name = 'Electrical Repair'),
    325.60,
    '2025-11-22',
    (SELECT id FROM branches WHERE name = 'Mississauga Branch'),
    'Canadian Tire Auto',
    'Sarah Martinez',
    288.13,
    37.47,
    'approved',
    58500,
    'Battery replacement and alternator test'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVH 001'),
    (SELECT id FROM expense_categories WHERE name = 'Electrical Repair'),
    275.80,
    '2025-11-25',
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    'Mr. Lube',
    'Lisa Gordon',
    244.07,
    31.73,
    'pending',
    40500,
    'Diagnostic and light repair'
  ),

-- Fuel receipts (November)
  (
    (SELECT id FROM vehicles WHERE plate = 'CVA 002'),
    (SELECT id FROM expense_categories WHERE name = 'Fuel'),
    71.23,
    '2025-11-04',
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    'Shell',
    'David Kumar',
    63.04,
    8.19,
    'approved',
    54200,
    'Premium fuel'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVB 001'),
    (SELECT id FROM expense_categories WHERE name = 'Fuel'),
    92.45,
    '2025-11-09',
    (SELECT id FROM branches WHERE name = 'Hamilton Branch'),
    'Petro-Canada',
    'Patricia Wong',
    81.81,
    10.64,
    'approved',
    92000,
    'Diesel fuel'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVD 001'),
    (SELECT id FROM expense_categories WHERE name = 'Fuel'),
    55.80,
    '2025-11-11',
    (SELECT id FROM branches WHERE name = 'Hamilton Branch'),
    'Esso',
    'Anthony Russo',
    49.38,
    6.42,
    'approved',
    98500,
    'Regular fuel'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVK 001'),
    (SELECT id FROM expense_categories WHERE name = 'Fuel'),
    48.50,
    '2025-11-16',
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    'Petro-Canada',
    'Jennifer Hayes',
    42.92,
    5.58,
    'approved',
    10200,
    'Electric charging'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVE 001'),
    (SELECT id FROM expense_categories WHERE name = 'Fuel'),
    84.65,
    '2025-11-19',
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    'Shell',
    'Kevin Patterson',
    74.91,
    9.74,
    'approved',
    47500,
    'Commercial diesel'
  ),

-- Transmission Repair (November)
  (
    (SELECT id FROM vehicles WHERE plate = 'CVG 001'),
    (SELECT id FROM expense_categories WHERE name = 'Transmission Repair'),
    420.35,
    '2025-11-23',
    (SELECT id FROM branches WHERE name = 'Hamilton Branch'),
    'Canadian Tire Auto',
    'Amanda Foster',
    371.98,
    48.37,
    'approved',
    22500,
    'Transmission fluid change'
  ),

-- December 2025 expenses (35 expenses - holiday season/winter prep)

-- Oil Changes (December)
  (
    (SELECT id FROM vehicles WHERE plate = 'CVA 001'),
    (SELECT id FROM expense_categories WHERE name = 'Oil Change'),
    101.45,
    '2025-12-02',
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    'Jiffy Lube',
    'Thomas Bell',
    89.78,
    11.67,
    'approved',
    18500,
    'Synthetic oil change'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVC 001'),
    (SELECT id FROM expense_categories WHERE name = 'Oil Change'),
    96.72,
    '2025-12-05',
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    'Mr. Lube',
    'Nicole Sanders',
    85.59,
    11.13,
    'approved',
    32000,
    'Van oil change'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVF 002'),
    (SELECT id FROM expense_categories WHERE name = 'Oil Change'),
    98.46,
    '2025-12-08',
    (SELECT id FROM branches WHERE name = 'Mississauga Branch'),
    'Canadian Tire Auto',
    'Marcus Thompson',
    87.04,
    11.31,
    'approved',
    60000,
    'Sedan oil change'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVH 001'),
    (SELECT id FROM expense_categories WHERE name = 'Oil Change'),
    114.58,
    '2025-12-10',
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    'Jiffy Lube',
    'James Chen',
    101.39,
    13.19,
    'approved',
    42000,
    'Heavy duty oil change'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVG 001'),
    (SELECT id FROM expense_categories WHERE name = 'Oil Change'),
    103.92,
    '2025-12-12',
    (SELECT id FROM branches WHERE name = 'Hamilton Branch'),
    'Mr. Lube',
    'Robert Walsh',
    91.97,
    11.95,
    'approved',
    24000,
    'Commercial vehicle oil'
  ),

-- Tire Replacements (December)
  (
    (SELECT id FROM vehicles WHERE plate = 'CVB 001'),
    (SELECT id FROM expense_categories WHERE name = 'Tire Replacement'),
    1045.89,
    '2025-12-03',
    (SELECT id FROM branches WHERE name = 'Hamilton Branch'),
    'Costco Tire Centre',
    'Sarah Martinez',
    925.66,
    120.23,
    'approved',
    95000,
    'Winter tires with installation - heavy truck'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVE 002'),
    (SELECT id FROM expense_categories WHERE name = 'Tire Replacement'),
    892.45,
    '2025-12-15',
    (SELECT id FROM branches WHERE name = 'Mississauga Branch'),
    'Canadian Tire Auto',
    'Patricia Wong',
    789.69,
    102.76,
    'approved',
    81500,
    'Winter commercial tires'
  ),

-- Brake Service (December)
  (
    (SELECT id FROM vehicles WHERE plate = 'CVA 002'),
    (SELECT id FROM expense_categories WHERE name = 'Brake Service'),
    565.43,
    '2025-12-18',
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    'Mr. Lube',
    'David Kumar',
    500.38,
    65.05,
    'approved',
    56000,
    'Brake pad replacement'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVI 001'),
    (SELECT id FROM expense_categories WHERE name = 'Brake Service'),
    425.60,
    '2025-12-20',
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    'Canadian Tire Auto',
    'Amanda Foster',
    376.73,
    48.87,
    'approved',
    51500,
    'Brake service inspection'
  ),

-- Air Filter (December)
  (
    (SELECT id FROM vehicles WHERE plate = 'CVD 001'),
    (SELECT id FROM expense_categories WHERE name = 'Air Filter'),
    171.34,
    '2025-12-07',
    (SELECT id FROM branches WHERE name = 'Hamilton Branch'),
    'Jiffy Lube',
    'Anthony Russo',
    151.60,
    19.74,
    'approved',
    99500,
    'Air filter replacement'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVG 002'),
    (SELECT id FROM expense_categories WHERE name = 'Air Filter'),
    158.45,
    '2025-12-14',
    (SELECT id FROM branches WHERE name = 'Hamilton Branch'),
    'Mr. Lube',
    'Jennifer Hayes',
    140.22,
    18.23,
    'approved',
    131000,
    'Engine air filter'
  ),

-- Electrical Repair (December)
  (
    (SELECT id FROM vehicles WHERE plate = 'CVJ 001'),
    (SELECT id FROM expense_categories WHERE name = 'Electrical Repair'),
    295.75,
    '2025-12-09',
    (SELECT id FROM branches WHERE name = 'Mississauga Branch'),
    'Canadian Tire Auto',
    'Kevin Patterson',
    261.55,
    34.20,
    'approved',
    35200,
    'Starter motor replacement'
  ),

-- Fuel receipts (December)
  (
    (SELECT id FROM vehicles WHERE plate = 'CVB 002'),
    (SELECT id FROM expense_categories WHERE name = 'Fuel'),
    86.50,
    '2025-12-04',
    (SELECT id FROM branches WHERE name = 'Hamilton Branch'),
    'Shell',
    'Lisa Gordon',
    76.55,
    9.95,
    'approved',
    158500,
    'Diesel fuel'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVH 002'),
    (SELECT id FROM expense_categories WHERE name = 'Fuel'),
    98.73,
    '2025-12-06',
    (SELECT id FROM branches WHERE name = 'Hamilton Branch'),
    'Petro-Canada',
    'Michael Brown',
    87.36,
    11.37,
    'approved',
    130000,
    'Premium diesel'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVC 002'),
    (SELECT id FROM expense_categories WHERE name = 'Fuel'),
    64.45,
    '2025-12-11',
    (SELECT id FROM branches WHERE name = 'Mississauga Branch'),
    'Esso',
    'James Chen',
    57.04,
    7.41,
    'approved',
    64500,
    'Regular fuel'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVE 001'),
    (SELECT id FROM expense_categories WHERE name = 'Fuel'),
    88.92,
    '2025-12-16',
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    'Shell',
    'Robert Walsh',
    78.70,
    10.22,
    'approved',
    48800,
    'Commercial diesel'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVK 001'),
    (SELECT id FROM expense_categories WHERE name = 'Fuel'),
    52.30,
    '2025-12-19',
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    'Petro-Canada',
    'Sarah Martinez',
    46.28,
    6.02,
    'approved',
    12100,
    'Electric charging'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVF 001'),
    (SELECT id FROM expense_categories WHERE name = 'Fuel'),
    62.80,
    '2025-12-21',
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    'Esso',
    'Patricia Wong',
    55.58,
    7.22,
    'approved',
    62500,
    'Regular fuel'
  ),

-- Transmission Repair (December)
  (
    (SELECT id FROM vehicles WHERE plate = 'CVA 001'),
    (SELECT id FROM expense_categories WHERE name = 'Transmission Repair'),
    380.25,
    '2025-12-22',
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    'Canadian Tire Auto',
    'Anthony Russo',
    336.43,
    43.82,
    'approved',
    19000,
    'Transmission fluid check and top-up'
  ),

-- Engine Repair (December)
  (
    (SELECT id FROM vehicles WHERE plate = 'CVG 001'),
    (SELECT id FROM expense_categories WHERE name = 'Engine Repair'),
    525.90,
    '2025-12-24',
    (SELECT id FROM branches WHERE name = 'Hamilton Branch'),
    'Mr. Lube',
    'Jennifer Hayes',
    465.27,
    60.63,
    'pending',
    25500,
    'Engine diagnostics and repair'
  ),

-- Suspension Repair (December)
  (
    (SELECT id FROM vehicles WHERE plate = 'CVH 002'),
    (SELECT id FROM expense_categories WHERE name = 'Suspension Repair'),
    685.40,
    '2025-12-27',
    (SELECT id FROM branches WHERE name = 'Hamilton Branch'),
    'Canadian Tire Auto',
    'Kevin Patterson',
    606.22,
    79.18,
    'approved',
    132000,
    'Suspension component replacement'
  ),

-- January 2026 expenses (32 expenses)

-- Oil Changes (January)
  (
    (SELECT id FROM vehicles WHERE plate = 'CVF 001'),
    (SELECT id FROM expense_categories WHERE name = 'Oil Change'),
    102.35,
    '2026-01-03',
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    'Jiffy Lube',
    'Amanda Foster',
    90.53,
    11.82,
    'approved',
    64000,
    'Synthetic oil change'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVC 002'),
    (SELECT id FROM expense_categories WHERE name = 'Oil Change'),
    98.57,
    '2026-01-06',
    (SELECT id FROM branches WHERE name = 'Mississauga Branch'),
    'Mr. Lube',
    'Thomas Bell',
    87.16,
    11.34,
    'approved',
    66000,
    'Van oil change'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVB 001'),
    (SELECT id FROM expense_categories WHERE name = 'Oil Change'),
    115.82,
    '2026-01-09',
    (SELECT id FROM branches WHERE name = 'Hamilton Branch'),
    'Canadian Tire Auto',
    'Nicole Sanders',
    102.50,
    13.32,
    'approved',
    97500,
    'Heavy truck oil change'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVE 001'),
    (SELECT id FROM expense_categories WHERE name = 'Oil Change'),
    99.48,
    '2026-01-12',
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    'Jiffy Lube',
    'Marcus Thompson',
    88.04,
    11.44,
    'approved',
    50000,
    'Commercial vehicle oil change'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVJ 001'),
    (SELECT id FROM expense_categories WHERE name = 'Oil Change'),
    101.67,
    '2026-01-15',
    (SELECT id FROM branches WHERE name = 'Mississauga Branch'),
    'Mr. Lube',
    'James Chen',
    89.97,
    11.70,
    'approved',
    37000,
    'Sedan oil change'
  ),

-- Tire Replacements (January)
  (
    (SELECT id FROM vehicles WHERE plate = 'CVI 001'),
    (SELECT id FROM expense_categories WHERE name = 'Tire Replacement'),
    775.43,
    '2026-01-05',
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    'Costco Tire Centre',
    'Robert Walsh',
    686.04,
    89.39,
    'approved',
    53000,
    'Winter tire replacement and balancing'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVG 002'),
    (SELECT id FROM expense_categories WHERE name = 'Tire Replacement'),
    1125.60,
    '2026-01-18',
    (SELECT id FROM branches WHERE name = 'Hamilton Branch'),
    'Canadian Tire Auto',
    'Sarah Martinez',
    996.46,
    129.54,
    'approved',
    133000,
    'Heavy duty winter tires - 4 tires'
  ),

-- Brake Service (January)
  (
    (SELECT id FROM vehicles WHERE plate = 'CVD 001'),
    (SELECT id FROM expense_categories WHERE name = 'Brake Service'),
    495.25,
    '2026-01-10',
    (SELECT id FROM branches WHERE name = 'Hamilton Branch'),
    'Mr. Lube',
    'Patricia Wong',
    438.28,
    56.97,
    'approved',
    100500,
    'Brake pad replacement and inspection'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVF 002'),
    (SELECT id FROM expense_categories WHERE name = 'Brake Service'),
    458.90,
    '2026-01-20',
    (SELECT id FROM branches WHERE name = 'Mississauga Branch'),
    'Canadian Tire Auto',
    'Anthony Russo',
    406.04,
    52.86,
    'approved',
    62000,
    'Brake service'
  ),

-- Air Filter (January)
  (
    (SELECT id FROM vehicles WHERE plate = 'CVA 002'),
    (SELECT id FROM expense_categories WHERE name = 'Air Filter'),
    159.32,
    '2026-01-08',
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    'Jiffy Lube',
    'Jennifer Hayes',
    141.00,
    18.32,
    'approved',
    57000,
    'Air filter replacement'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVH 001'),
    (SELECT id FROM expense_categories WHERE name = 'Air Filter'),
    167.45,
    '2026-01-14',
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    'Mr. Lube',
    'Kevin Patterson',
    148.10,
    19.25,
    'approved',
    44000,
    'Heavy truck air filter'
  ),

-- Electrical Repair (January)
  (
    (SELECT id FROM vehicles WHERE plate = 'CVE 002'),
    (SELECT id FROM expense_categories WHERE name = 'Electrical Repair'),
    285.60,
    '2026-01-07',
    (SELECT id FROM branches WHERE name = 'Mississauga Branch'),
    'Canadian Tire Auto',
    'Lisa Gordon',
    252.74,
    32.86,
    'approved',
    83000,
    'Battery test and cleaning'
  ),

-- Fuel receipts (January)
  (
    (SELECT id FROM vehicles WHERE plate = 'CVA 001'),
    (SELECT id FROM expense_categories WHERE name = 'Fuel'),
    74.35,
    '2026-01-04',
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    'Shell',
    'Michael Brown',
    65.80,
    8.55,
    'approved',
    20000,
    'Premium fuel'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVB 002'),
    (SELECT id FROM expense_categories WHERE name = 'Fuel'),
    95.80,
    '2026-01-11',
    (SELECT id FROM branches WHERE name = 'Hamilton Branch'),
    'Petro-Canada',
    'Amanda Foster',
    84.78,
    11.02,
    'approved',
    160000,
    'Diesel fuel'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVG 001'),
    (SELECT id FROM expense_categories WHERE name = 'Fuel'),
    89.45,
    '2026-01-13',
    (SELECT id FROM branches WHERE name = 'Hamilton Branch'),
    'Shell',
    'Thomas Bell',
    79.16,
    10.29,
    'approved',
    26000,
    'Premium diesel'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVK 001'),
    (SELECT id FROM expense_categories WHERE name = 'Fuel'),
    51.20,
    '2026-01-16',
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    'Esso',
    'Nicole Sanders',
    45.33,
    5.89,
    'approved',
    14500,
    'Electric charging'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVC 001'),
    (SELECT id FROM expense_categories WHERE name = 'Fuel'),
    67.90,
    '2026-01-19',
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    'Petro-Canada',
    'James Chen',
    60.09,
    7.81,
    'approved',
    34000,
    'Regular fuel'
  ),

-- Transmission Repair (January)
  (
    (SELECT id FROM vehicles WHERE plate = 'CVG 002'),
    (SELECT id FROM expense_categories WHERE name = 'Transmission Repair'),
    425.50,
    '2026-01-21',
    (SELECT id FROM branches WHERE name = 'Hamilton Branch'),
    'Mr. Lube',
    'Robert Walsh',
    376.55,
    48.95,
    'approved',
    134000,
    'Transmission fluid change'
  ),

-- Suspension Repair (January)
  (
    (SELECT id FROM vehicles WHERE plate = 'CVA 001'),
    (SELECT id FROM expense_categories WHERE name = 'Suspension Repair'),
    565.80,
    '2026-01-22',
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    'Canadian Tire Auto',
    'Sarah Martinez',
    500.71,
    65.09,
    'pending',
    21000,
    'Suspension check and adjustment'
  ),

-- February 2026 expenses (32 expenses)

-- Oil Changes (February)
  (
    (SELECT id FROM vehicles WHERE plate = 'CVD 001'),
    (SELECT id FROM expense_categories WHERE name = 'Oil Change'),
    110.43,
    '2026-02-02',
    (SELECT id FROM branches WHERE name = 'Hamilton Branch'),
    'Jiffy Lube',
    'Patricia Wong',
    97.73,
    12.70,
    'approved',
    102000,
    'Service van oil change'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVE 002'),
    (SELECT id FROM expense_categories WHERE name = 'Oil Change'),
    100.25,
    '2026-02-05',
    (SELECT id FROM branches WHERE name = 'Mississauga Branch'),
    'Mr. Lube',
    'Anthony Russo',
    88.81,
    11.54,
    'approved',
    85000,
    'Commercial vehicle oil change'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVH 001'),
    (SELECT id FROM expense_categories WHERE name = 'Oil Change'),
    114.60,
    '2026-02-08',
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    'Canadian Tire Auto',
    'Jennifer Hayes',
    101.42,
    13.18,
    'approved',
    45000,
    'Heavy truck oil change'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVI 001'),
    (SELECT id FROM expense_categories WHERE name = 'Oil Change'),
    99.35,
    '2026-02-11',
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    'Jiffy Lube',
    'Kevin Patterson',
    87.92,
    11.43,
    'approved',
    55000,
    'Sedan oil change'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVJ 001'),
    (SELECT id FROM expense_categories WHERE name = 'Oil Change'),
    103.48,
    '2026-02-14',
    (SELECT id FROM branches WHERE name = 'Mississauga Branch'),
    'Mr. Lube',
    'Lisa Gordon',
    91.57,
    11.91,
    'approved',
    38500,
    'Vehicle maintenance'
  ),

-- Tire Replacements (February)
  (
    (SELECT id FROM vehicles WHERE plate = 'CVB 001'),
    (SELECT id FROM expense_categories WHERE name = 'Tire Replacement'),
    925.45,
    '2026-02-03',
    (SELECT id FROM branches WHERE name = 'Hamilton Branch'),
    'Costco Tire Centre',
    'Michael Brown',
    819.06,
    106.39,
    'approved',
    99000,
    'Tire replacement with balancing'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVG 001'),
    (SELECT id FROM expense_categories WHERE name = 'Tire Replacement'),
    1012.50,
    '2026-02-16',
    (SELECT id FROM branches WHERE name = 'Hamilton Branch'),
    'Canadian Tire Auto',
    'Amanda Foster',
    895.58,
    116.42,
    'approved',
    27000,
    'Commercial tire installation'
  ),

-- Brake Service (February)
  (
    (SELECT id FROM vehicles WHERE plate = 'CVA 002'),
    (SELECT id FROM expense_categories WHERE name = 'Brake Service'),
    502.75,
    '2026-02-09',
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    'Mr. Lube',
    'Thomas Bell',
    445.04,
    57.71,
    'approved',
    58500,
    'Brake pad and rotor replacement'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVF 001'),
    (SELECT id FROM expense_categories WHERE name = 'Brake Service'),
    440.20,
    '2026-02-18',
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    'Canadian Tire Auto',
    'Nicole Sanders',
    389.38,
    50.82,
    'approved',
    65500,
    'Brake service inspection'
  ),

-- Air Filter (February)
  (
    (SELECT id FROM vehicles WHERE plate = 'CVG 002'),
    (SELECT id FROM expense_categories WHERE name = 'Air Filter'),
    162.35,
    '2026-02-07',
    (SELECT id FROM branches WHERE name = 'Hamilton Branch'),
    'Jiffy Lube',
    'Robert Walsh',
    143.63,
    18.67,
    'approved',
    135000,
    'Air filter replacement'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVE 001'),
    (SELECT id FROM expense_categories WHERE name = 'Air Filter'),
    155.48,
    '2026-02-13',
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    'Mr. Lube',
    'Sarah Martinez',
    137.59,
    17.89,
    'approved',
    51500,
    'Engine air filter'
  ),

-- Electrical Repair (February)
  (
    (SELECT id FROM vehicles WHERE plate = 'CVJ 001'),
    (SELECT id FROM expense_categories WHERE name = 'Electrical Repair'),
    310.45,
    '2026-02-10',
    (SELECT id FROM branches WHERE name = 'Mississauga Branch'),
    'Canadian Tire Auto',
    'James Chen',
    274.82,
    35.63,
    'approved',
    39000,
    'Headlight replacement'
  ),

-- Fuel receipts (February)
  (
    (SELECT id FROM vehicles WHERE plate = 'CVB 001'),
    (SELECT id FROM expense_categories WHERE name = 'Fuel'),
    91.75,
    '2026-02-04',
    (SELECT id FROM branches WHERE name = 'Hamilton Branch'),
    'Shell',
    'Patricia Wong',
    81.19,
    10.56,
    'approved',
    100500,
    'Diesel fuel'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVH 002'),
    (SELECT id FROM expense_categories WHERE name = 'Fuel'),
    99.30,
    '2026-02-06',
    (SELECT id FROM branches WHERE name = 'Hamilton Branch'),
    'Petro-Canada',
    'Anthony Russo',
    87.87,
    11.43,
    'approved',
    136000,
    'Premium diesel'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVC 001'),
    (SELECT id FROM expense_categories WHERE name = 'Fuel'),
    72.45,
    '2026-02-12',
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    'Esso',
    'Jennifer Hayes',
    64.11,
    8.34,
    'approved',
    35500,
    'Regular fuel'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVK 001'),
    (SELECT id FROM expense_categories WHERE name = 'Fuel'),
    54.80,
    '2026-02-15',
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    'Petro-Canada',
    'Kevin Patterson',
    48.50,
    6.30,
    'approved',
    16000,
    'Electric charging'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVF 002'),
    (SELECT id FROM expense_categories WHERE name = 'Fuel'),
    68.50,
    '2026-02-17',
    (SELECT id FROM branches WHERE name = 'Mississauga Branch'),
    'Shell',
    'Lisa Gordon',
    60.62,
    7.88,
    'approved',
    64500,
    'Regular fuel'
  ),

-- Transmission Repair (February)
  (
    (SELECT id FROM vehicles WHERE plate = 'CVA 001'),
    (SELECT id FROM expense_categories WHERE name = 'Transmission Repair'),
    395.75,
    '2026-02-19',
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    'Canadian Tire Auto',
    'Michael Brown',
    350.22,
    45.53,
    'approved',
    22500,
    'Transmission fluid and filter service'
  ),

-- Engine Repair (February)
  (
    (SELECT id FROM vehicles WHERE plate = 'CVD 001'),
    (SELECT id FROM expense_categories WHERE name = 'Engine Repair'),
    480.50,
    '2026-02-20',
    (SELECT id FROM branches WHERE name = 'Hamilton Branch'),
    'Mr. Lube',
    'Amanda Foster',
    425.22,
    55.28,
    'pending',
    103000,
    'Engine diagnostics'
  ),

-- March 2026 expenses (32 expenses - spring maintenance)

-- Oil Changes (March)
  (
    (SELECT id FROM vehicles WHERE plate = 'CVA 001'),
    (SELECT id FROM expense_categories WHERE name = 'Oil Change'),
    104.28,
    '2026-03-02',
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    'Jiffy Lube',
    'Thomas Bell',
    92.27,
    11.99,
    'approved',
    23000,
    'Synthetic oil change'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVE 001'),
    (SELECT id FROM expense_categories WHERE name = 'Oil Change'),
    100.56,
    '2026-03-05',
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    'Mr. Lube',
    'Nicole Sanders',
    89.07,
    11.58,
    'approved',
    52500,
    'Commercial vehicle oil'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVC 002'),
    (SELECT id FROM expense_categories WHERE name = 'Oil Change'),
    99.32,
    '2026-03-08',
    (SELECT id FROM branches WHERE name = 'Mississauga Branch'),
    'Canadian Tire Auto',
    'James Chen',
    87.89,
    11.43,
    'approved',
    68000,
    'Van oil change'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVF 002'),
    (SELECT id FROM expense_categories WHERE name = 'Oil Change'),
    101.45,
    '2026-03-11',
    (SELECT id FROM branches WHERE name = 'Mississauga Branch'),
    'Jiffy Lube',
    'Robert Walsh',
    89.78,
    11.67,
    'approved',
    66000,
    'Sedan maintenance'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVH 001'),
    (SELECT id FROM expense_categories WHERE name = 'Oil Change'),
    115.60,
    '2026-03-14',
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    'Mr. Lube',
    'Sarah Martinez',
    102.39,
    13.21,
    'approved',
    47000,
    'Heavy truck oil'
  ),

-- Tire Replacements (March - spring change)
  (
    (SELECT id FROM vehicles WHERE plate = 'CVA 002'),
    (SELECT id FROM expense_categories WHERE name = 'Tire Replacement'),
    845.90,
    '2026-03-03',
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    'Costco Tire Centre',
    'Patricia Wong',
    748.50,
    97.40,
    'approved',
    60000,
    'Summer tire installation'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVG 002'),
    (SELECT id FROM expense_categories WHERE name = 'Tire Replacement'),
    1085.75,
    '2026-03-15',
    (SELECT id FROM branches WHERE name = 'Hamilton Branch'),
    'Canadian Tire Auto',
    'Anthony Russo',
    960.75,
    125.00,
    'approved',
    137000,
    'Heavy duty summer tires'
  ),

-- Brake Service (March)
  (
    (SELECT id FROM vehicles WHERE plate = 'CVI 001'),
    (SELECT id FROM expense_categories WHERE name = 'Brake Service'),
    455.40,
    '2026-03-09',
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    'Mr. Lube',
    'Jennifer Hayes',
    403.01,
    52.39,
    'approved',
    57000,
    'Brake maintenance'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVB 001'),
    (SELECT id FROM expense_categories WHERE name = 'Brake Service'),
    585.65,
    '2026-03-17',
    (SELECT id FROM branches WHERE name = 'Hamilton Branch'),
    'Canadian Tire Auto',
    'Kevin Patterson',
    518.26,
    67.39,
    'approved',
    101000,
    'Heavy truck brake service'
  ),

-- Air Filter (March)
  (
    (SELECT id FROM vehicles WHERE plate = 'CVD 001'),
    (SELECT id FROM expense_categories WHERE name = 'Air Filter'),
    168.50,
    '2026-03-07',
    (SELECT id FROM branches WHERE name = 'Hamilton Branch'),
    'Jiffy Lube',
    'Lisa Gordon',
    149.12,
    19.38,
    'approved',
    105000,
    'Air filter replacement'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVG 001'),
    (SELECT id FROM expense_categories WHERE name = 'Air Filter'),
    160.45,
    '2026-03-12',
    (SELECT id FROM branches WHERE name = 'Hamilton Branch'),
    'Mr. Lube',
    'Michael Brown',
    141.99,
    18.46,
    'approved',
    28500,
    'Commercial air filter'
  ),

-- Electrical Repair (March)
  (
    (SELECT id FROM vehicles WHERE plate = 'CVE 002'),
    (SELECT id FROM expense_categories WHERE name = 'Electrical Repair'),
    325.80,
    '2026-03-10',
    (SELECT id FROM branches WHERE name = 'Mississauga Branch'),
    'Canadian Tire Auto',
    'Amanda Foster',
    288.50,
    37.50,
    'approved',
    86500,
    'Alternator test and service'
  ),

-- Fuel receipts (March)
  (
    (SELECT id FROM vehicles WHERE plate = 'CVA 001'),
    (SELECT id FROM expense_categories WHERE name = 'Fuel'),
    76.50,
    '2026-03-04',
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    'Shell',
    'Thomas Bell',
    67.70,
    8.80,
    'approved',
    24500,
    'Premium fuel'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVB 002'),
    (SELECT id FROM expense_categories WHERE name = 'Fuel'),
    98.60,
    '2026-03-06',
    (SELECT id FROM branches WHERE name = 'Hamilton Branch'),
    'Petro-Canada',
    'Nicole Sanders',
    87.25,
    11.35,
    'approved',
    162000,
    'Diesel fuel'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVH 002'),
    (SELECT id FROM expense_categories WHERE name = 'Fuel'),
    87.45,
    '2026-03-13',
    (SELECT id FROM branches WHERE name = 'Hamilton Branch'),
    'Shell',
    'James Chen',
    77.39,
    10.06,
    'approved',
    138500,
    'Premium diesel'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVK 001'),
    (SELECT id FROM expense_categories WHERE name = 'Fuel'),
    55.30,
    '2026-03-16',
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    'Esso',
    'Robert Walsh',
    48.94,
    6.36,
    'approved',
    17800,
    'Electric charging'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVC 001'),
    (SELECT id FROM expense_categories WHERE name = 'Fuel'),
    70.80,
    '2026-03-18',
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    'Petro-Canada',
    'Sarah Martinez',
    62.65,
    8.15,
    'approved',
    36000,
    'Regular fuel'
  ),

-- Transmission Repair (March)
  (
    (SELECT id FROM vehicles WHERE plate = 'CVG 001'),
    (SELECT id FROM expense_categories WHERE name = 'Transmission Repair'),
    410.25,
    '2026-03-19',
    (SELECT id FROM branches WHERE name = 'Hamilton Branch'),
    'Mr. Lube',
    'Patricia Wong',
    363.05,
    47.20,
    'approved',
    29000,
    'Transmission maintenance fluid'
  ),

-- Suspension Repair (March)
  (
    (SELECT id FROM vehicles WHERE plate = 'CVF 001'),
    (SELECT id FROM expense_categories WHERE name = 'Suspension Repair'),
    595.80,
    '2026-03-20',
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    'Canadian Tire Auto',
    'Anthony Russo',
    527.17,
    68.63,
    'approved',
    67000,
    'Suspension component inspection'
  )
ON CONFLICT DO NOTHING;

-- ============================================================
-- 4. TIRE CHANGES (at least 8 vehicles with summer/winter data)
-- ============================================================

INSERT INTO tire_changes (
  vehicle_id, branch_id, tire_type, current_tire_type,
  change_date, summer_tire_location, winter_tire_location,
  notes, completed_by
)
VALUES
  (
    (SELECT id FROM vehicles WHERE plate = 'CVA 001'),
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    'winter',
    'winter',
    '2025-10-15',
    'Warehouse A',
    'Vehicle bay 1',
    'Switched to winter tires for November - April'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVA 001'),
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    'summer',
    'summer',
    '2026-03-01',
    'Vehicle bay 1',
    'Storage room B',
    'Spring changeover to summer tires'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVB 001'),
    (SELECT id FROM branches WHERE name = 'Hamilton Branch'),
    'winter',
    'winter',
    '2025-11-01',
    'Garage B',
    'Vehicle dock',
    'Winter preparation complete'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVB 001'),
    (SELECT id FROM branches WHERE name = 'Hamilton Branch'),
    'summer',
    'summer',
    '2026-02-28',
    'Vehicle dock',
    'Garage B',
    'Spring changeover initiated'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVC 001'),
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    'winter',
    'all_season',
    '2025-10-20',
    'Service bay 2',
    'Main warehouse',
    'Service van - all season to winter'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVE 001'),
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    'winter',
    'summer',
    '2025-11-05',
    'Parking lot storage',
    'Vehicle bay 2',
    'Commercial van winter setup'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVE 001'),
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    'summer',
    'winter',
    '2026-03-05',
    'Vehicle bay 2',
    'Parking lot storage',
    'Back to summer tires for spring'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVF 001'),
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    'winter',
    'summer',
    '2025-10-25',
    'Tire storage A',
    'Bay 3',
    'Executive car winter tires installed'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVF 001'),
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    'summer',
    'winter',
    '2026-03-10',
    'Bay 3',
    'Tire storage A',
    'Return to summer performance tires'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVG 001'),
    (SELECT id FROM branches WHERE name = 'Hamilton Branch'),
    'winter',
    'summer',
    '2025-10-30',
    'Service yard',
    'Indoor garage',
    'Heavy truck winter prep'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVG 001'),
    (SELECT id FROM branches WHERE name = 'Hamilton Branch'),
    'summer',
    'winter',
    '2026-03-08',
    'Indoor garage',
    'Service yard',
    'Spring changeover heavy truck'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVJ 001'),
    (SELECT id FROM branches WHERE name = 'Mississauga Branch'),
    'winter',
    'all_season',
    '2025-11-10',
    'Tire shop storage',
    'Vehicle lot',
    'Corporate vehicle winter prep'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVI 001'),
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    'winter',
    'summer',
    '2025-11-02',
    'Manager lot storage',
    'Service bay 1',
    'Manager vehicle winter tires'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVI 001'),
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    'summer',
    'winter',
    '2026-03-15',
    'Service bay 1',
    'Manager lot storage',
    'Manager vehicle spring changeover'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVH 001'),
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    'winter',
    'summer',
    '2025-10-28',
    'Fleet yard A',
    'Heavy equipment bay',
    'Heavy truck winter setup'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVH 001'),
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    'summer',
    'winter',
    '2026-03-12',
    'Heavy equipment bay',
    'Fleet yard A',
    'Heavy truck spring changeover'
  )
ON CONFLICT DO NOTHING;

-- ============================================================
-- 5. VEHICLE INSPECTIONS (at least 12 vehicles, monthly over 3 months)
-- ============================================================

-- December 2025 inspections
INSERT INTO vehicle_inspections (
  vehicle_id, branch_id, inspection_date, inspection_month,
  kilometers, brakes_pass, brakes_notes,
  engine_pass, engine_notes, transmission_pass, transmission_notes,
  tires_pass, tires_notes, headlights_pass, headlights_notes,
  signal_lights_pass, signal_lights_notes, oil_level_pass, oil_level_notes,
  windshield_fluid_pass, windshield_fluid_notes, wipers_pass, wipers_notes,
  completed_by, general_notes
)
VALUES
  (
    (SELECT id FROM vehicles WHERE plate = 'CVA 001'),
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    '2025-12-05',
    '2025-12-01',
    18500,
    true, 'Brake pads have good thickness',
    true, 'Engine running smoothly',
    true, 'Transmission fluid clear',
    true, 'Winter tires in good condition',
    true, 'Both headlights functioning',
    true, 'Turn signals operational',
    true, 'Oil level normal',
    true, 'Washer fluid full',
    true, 'Wipers working well',
    'Test inspection - all systems pass'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVA 002'),
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    '2025-12-08',
    '2025-12-01',
    56000,
    false, 'Front brake pads worn - recommend replacement within 500km',
    true, 'Engine temperature normal',
    true, 'Transmission operating normally',
    true, 'Tires properly inflated',
    true, 'Headlights clear and bright',
    true, 'Signal lights working',
    true, 'Oil level adequate',
    true, 'Washer fluid topped up',
    true, 'Wiper blades functional',
    'High mileage vehicle - brake service recommended'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVB 001'),
    (SELECT id FROM branches WHERE name = 'Hamilton Branch'),
    '2025-12-10',
    '2025-12-01',
    95000,
    true, 'All brake pads within limits',
    true, 'Engine diagnostics normal',
    true, 'Transmission shifting smoothly',
    true, 'Winter tires properly installed',
    true, 'Both headlights functional',
    true, 'All signals operational',
    true, 'Oil level checked',
    true, 'Washer reservoir full',
    true, 'Wipers in good condition',
    'Heavy truck maintenance on schedule'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVC 001'),
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    '2025-12-12',
    '2025-12-01',
    32000,
    true, 'Brake condition good',
    true, 'Engine running well',
    true, 'All gears functioning',
    true, 'Tires suitable for service',
    true, 'Headlights operational',
    true, 'Turn signals working',
    true, 'Oil level normal',
    true, 'Washer fluid available',
    true, 'Wipers functional',
    'Service van - routine maintenance complete'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVE 001'),
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    '2025-12-15',
    '2025-12-01',
    45000,
    true, 'Brakes in good working order',
    true, 'Engine performing normally',
    true, 'Transmission responsive',
    true, 'Winter tires appropriate',
    false, 'Right headlight dim - replace soon',
    true, 'Signal lights clear',
    true, 'Oil level satisfactory',
    true, 'Washer fluid full',
    true, 'Wiper blades adequate',
    'Replace right headlight - recommend LED upgrade'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVF 001'),
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    '2025-12-18',
    '2025-12-01',
    64000,
    true, 'Brake pads healthy',
    true, 'Engine smooth operation',
    true, 'All transmissions engaged',
    true, 'Tire tread adequate',
    true, 'Headlights clear',
    true, 'Signal lights functional',
    true, 'Oil level normal',
    true, 'Washer fluid adequate',
    true, 'Wipers performing well',
    'Executive vehicle - excellent condition'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVG 001'),
    (SELECT id FROM branches WHERE name = 'Hamilton Branch'),
    '2025-12-20',
    '2025-12-01',
    25500,
    true, 'Brake system in good condition',
    true, 'Engine running properly',
    true, 'Heavy duty transmission normal',
    true, 'Heavy truck tires good',
    true, 'All lights operational',
    true, 'Signal lights working',
    true, 'Oil level checked',
    false, 'Washer fluid low - refill needed',
    true, 'Wipers functional',
    'Heavy truck service complete - refill washer fluid'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVG 002'),
    (SELECT id FROM branches WHERE name = 'Hamilton Branch'),
    '2025-12-22',
    '2025-12-01',
    131000,
    false, 'Rear brake pads require immediate attention',
    true, 'Engine performance adequate',
    true, 'Transmission operating',
    true, 'Tires in acceptable condition',
    true, 'Headlights working',
    true, 'Signals functional',
    true, 'Oil level normal',
    true, 'Washer fluid full',
    true, 'Wipers in service',
    'URGENT: Schedule brake service for rear axle immediately'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVI 001'),
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    '2025-12-25',
    '2025-12-01',
    51500,
    true, 'Brake system excellent',
    true, 'Engine condition good',
    true, 'Transmission smooth',
    true, 'Winter tires properly fitted',
    true, 'Headlights bright',
    true, 'Turn signals operational',
    true, 'Oil level adequate',
    true, 'Washer fluid topped',
    true, 'Wiper blades good',
    'Manager vehicle inspection passed'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVH 001'),
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    '2025-12-28',
    '2025-12-01',
    42000,
    true, 'Brake condition normal',
    true, 'Engine diagnostics clear',
    true, 'Transmission responsive',
    true, 'Tires properly balanced',
    true, 'Headlights functional',
    true, 'Signal lights working',
    true, 'Oil level satisfactory',
    true, 'Washer fluid full',
    true, 'Wipers effective',
    'Heavy duty truck well-maintained'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVJ 001'),
    (SELECT id FROM branches WHERE name = 'Mississauga Branch'),
    '2025-12-30',
    '2025-12-01',
    35200,
    true, 'Brake pads within spec',
    true, 'Engine running well',
    true, 'Transmission engaging properly',
    true, 'Tires at correct pressure',
    true, 'Headlights clear',
    true, 'Signals all working',
    true, 'Oil level good',
    true, 'Washer fluid present',
    true, 'Wipers functioning',
    'Corporate vehicle - all systems normal'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVK 001'),
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    '2025-12-31',
    '2025-12-01',
    12100,
    true, 'Brake system optimal',
    true, 'Electric motor healthy',
    true, 'Transmission fluid level normal',
    true, 'Tires properly inflated',
    true, 'Headlights LED functional',
    true, 'Signal lights working',
    true, 'Coolant level adequate',
    true, 'Washer fluid full',
    true, 'Wipers in good condition',
    'Executive electric vehicle - excellent condition'
  ),

-- January 2026 inspections
  (
    (SELECT id FROM vehicles WHERE plate = 'CVA 001'),
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    '2026-01-08',
    '2026-01-01',
    20000,
    true, 'Brake pads still good',
    true, 'Engine performing well',
    true, 'Transmission normal',
    true, 'Winter tires adequate',
    true, 'Headlights bright',
    true, 'Signals operational',
    true, 'Oil level normal',
    true, 'Washer fluid full',
    true, 'Wipers working',
    'Monthly inspection - all systems pass'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVB 001'),
    (SELECT id FROM branches WHERE name = 'Hamilton Branch'),
    '2026-01-10',
    '2026-01-01',
    97500,
    true, 'Brakes serviceable',
    true, 'Engine diagnostics clear',
    true, 'Transmission operating normally',
    true, 'Winter tires in good shape',
    true, 'Headlights functional',
    true, 'Turn signals working',
    true, 'Oil level adequate',
    true, 'Washer fluid topped',
    true, 'Wiper blades functional',
    'High-mileage truck - continued maintenance needed'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVC 001'),
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    '2026-01-12',
    '2026-01-01',
    34000,
    true, 'Brake condition good',
    true, 'Engine smooth',
    true, 'Transmission responsive',
    true, 'Tires suitable',
    true, 'Headlights clear',
    true, 'Signals working',
    true, 'Oil level normal',
    true, 'Washer fluid available',
    true, 'Wipers functional',
    'Service van - routine maintenance'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVE 001'),
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    '2026-01-15',
    '2026-01-01',
    50000,
    true, 'Brakes in service',
    true, 'Engine normal',
    true, 'Transmission engaged',
    true, 'Winter tires appropriate',
    true, 'Headlights replaced and working',
    true, 'Signals clear',
    true, 'Oil level satisfactory',
    true, 'Washer fluid full',
    true, 'Wipers adequate',
    'Right headlight replacement confirmed - working well'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVF 001'),
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    '2026-01-18',
    '2026-01-01',
    65500,
    true, 'Brakes healthy',
    true, 'Engine condition excellent',
    true, 'Transmission normal operation',
    true, 'Tire tread adequate',
    true, 'Headlights optimal',
    true, 'Signal lights functional',
    true, 'Oil level normal',
    true, 'Washer fluid adequate',
    true, 'Wipers performing',
    'Executive vehicle - premium condition maintained'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVG 001'),
    (SELECT id FROM branches WHERE name = 'Hamilton Branch'),
    '2026-01-20',
    '2026-01-01',
    26000,
    true, 'Brake system maintained',
    true, 'Engine operating normally',
    true, 'Transmission functioning',
    true, 'Heavy truck tires good',
    true, 'Lights operational',
    true, 'Signals working',
    true, 'Oil level checked',
    true, 'Washer fluid refilled',
    true, 'Wipers functional',
    'Heavy truck - maintenance current'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVG 002'),
    (SELECT id FROM branches WHERE name = 'Hamilton Branch'),
    '2026-01-22',
    '2026-01-01',
    134000,
    true, 'Rear brake service completed',
    true, 'Engine diagnostics normal',
    true, 'Transmission performing',
    true, 'Tires in good condition',
    true, 'All lights working',
    true, 'Signals operational',
    true, 'Oil level normal',
    true, 'Washer fluid full',
    true, 'Wipers in service',
    'Brake service completed per December recommendations'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVI 001'),
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    '2026-01-25',
    '2026-01-01',
    53000,
    true, 'Brake system excellent',
    true, 'Engine condition good',
    true, 'Transmission smooth',
    true, 'Winter tires fitted well',
    true, 'Headlights bright',
    true, 'Signals optimal',
    true, 'Oil level adequate',
    true, 'Washer fluid full',
    true, 'Wipers working well',
    'Manager vehicle - all systems excellent'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVH 001'),
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    '2026-01-28',
    '2026-01-01',
    44000,
    true, 'Brake condition normal',
    true, 'Engine clear diagnostics',
    true, 'Transmission responsive',
    true, 'Tires properly maintained',
    true, 'Headlights functional',
    true, 'Signals working',
    true, 'Oil level normal',
    true, 'Washer fluid topped',
    true, 'Wipers effective',
    'Heavy duty truck - well-maintained'
  ),

-- February 2026 inspections
  (
    (SELECT id FROM vehicles WHERE plate = 'CVA 001'),
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    '2026-02-05',
    '2026-02-01',
    22500,
    true, 'Brake pads adequate',
    true, 'Engine running smoothly',
    true, 'Transmission fluid normal',
    true, 'Winter tires still serviceable',
    true, 'Headlights clear',
    true, 'Signals working',
    true, 'Oil level normal',
    true, 'Washer fluid full',
    true, 'Wipers functional',
    'Monthly inspection - pre-spring check'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVB 001'),
    (SELECT id FROM branches WHERE name = 'Hamilton Branch'),
    '2026-02-08',
    '2026-02-01',
    99000,
    true, 'Brakes maintain good condition',
    true, 'Engine diagnostics normal',
    true, 'Transmission operating',
    true, 'Winter tires adequate for season',
    true, 'Headlights working',
    true, 'Signals functional',
    true, 'Oil level satisfactory',
    true, 'Washer fluid adequate',
    true, 'Wipers in service',
    'High-mileage truck - spring maintenance prep'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVC 001'),
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    '2026-02-10',
    '2026-02-01',
    35500,
    true, 'Brake condition excellent',
    true, 'Engine performing well',
    true, 'Transmission engaging properly',
    true, 'Tires ready for spring',
    true, 'Headlights clear',
    true, 'Signals all working',
    true, 'Oil level adequate',
    true, 'Washer fluid present',
    true, 'Wipers functioning',
    'Service van - pre-spring maintenance complete'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVE 001'),
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    '2026-02-12',
    '2026-02-01',
    51500,
    true, 'Brakes in good working order',
    true, 'Engine condition good',
    true, 'Transmission normal',
    true, 'Winter tires preparing for changeover',
    true, 'Headlights optimal',
    true, 'Signals clear',
    true, 'Oil level normal',
    true, 'Washer fluid full',
    true, 'Wipers adequate',
    'Commercial van - ready for spring changeover'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVF 001'),
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    '2026-02-15',
    '2026-02-01',
    67000,
    true, 'Brake system excellent',
    true, 'Engine excellent condition',
    true, 'Transmission smooth operation',
    true, 'Tire condition good',
    true, 'Headlights bright',
    true, 'Signals working',
    true, 'Oil level optimal',
    true, 'Washer fluid full',
    true, 'Wipers performing well',
    'Executive vehicle - spring ready'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVG 001'),
    (SELECT id FROM branches WHERE name = 'Hamilton Branch'),
    '2026-02-18',
    '2026-02-01',
    27000,
    true, 'Brake system normal',
    true, 'Engine operating normally',
    true, 'Transmission functioning well',
    true, 'Heavy truck tires serviceable',
    true, 'All lights operational',
    true, 'Signals working',
    true, 'Oil level checked',
    true, 'Washer fluid refilled',
    true, 'Wipers functional',
    'Heavy truck - spring maintenance due soon'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVG 002'),
    (SELECT id FROM branches WHERE name = 'Hamilton Branch'),
    '2026-02-20',
    '2026-02-01',
    136000,
    true, 'Brake system well-maintained',
    true, 'Engine diagnostics clear',
    true, 'Transmission performing well',
    true, 'Tires in good condition',
    true, 'Lights all functional',
    true, 'Signals operational',
    true, 'Oil level normal',
    true, 'Washer fluid adequate',
    true, 'Wipers in service',
    'High-mileage heavy truck - condition stable'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVI 001'),
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    '2026-02-22',
    '2026-02-01',
    55000,
    true, 'Brake system maintained',
    true, 'Engine in excellent condition',
    true, 'Transmission responsive',
    true, 'Winter tires ready for changeover',
    true, 'Headlights excellent',
    true, 'Signals working',
    true, 'Oil level adequate',
    true, 'Washer fluid full',
    true, 'Wipers functional',
    'Manager vehicle - spring-ready'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVH 001'),
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    '2026-02-25',
    '2026-02-01',
    47000,
    true, 'Brake condition normal',
    true, 'Engine diagnostics normal',
    true, 'Transmission responsive',
    true, 'Tires properly maintained',
    true, 'Headlights functional',
    true, 'Signals working',
    true, 'Oil level satisfactory',
    true, 'Washer fluid adequate',
    true, 'Wipers effective',
    'Heavy duty truck - consistently maintained'
  )
ON CONFLICT DO NOTHING;

-- ============================================================
-- TRANSACTION COMPLETION
-- ============================================================

COMMIT;

-- ============================================================
-- SUMMARY OF SEED DATA
-- ============================================================
--
-- Branches: 3
-- Vehicles: 18 (mostly active, 2 in maintenance, 1 retired)
-- Expenses: ~180 total (Oct 2025 - Mar 2026)
-- Tire Changes: 16 records across 8 vehicles
-- Vehicle Inspections: 40 monthly records across 12 vehicles
-- All amounts in CAD with 13% HST
-- All dates realistic for demo purposes
--
-- ============================================================
