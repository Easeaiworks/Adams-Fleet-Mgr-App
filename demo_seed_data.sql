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

INSERT INTO branches (name, location)
VALUES
  (
    'Main Office - Toronto',
    '45 Queen Street West, Toronto, ON M5H 2R3'
  ),
  (
    'Hamilton Location',
    '100 Main Street, Hamilton, ON L8P 1H6'
  ),
  (
    'Mississauga Location',
    '2300 Douglas Point Drive, Mississauga, ON L5L 1J3'
  )
ON CONFLICT DO NOTHING;

-- ============================================================
-- 2. VEHICLES (18 vehicles distributed across branches)
-- ============================================================

-- Ford F-150s (4 trucks, 2020-2024)
INSERT INTO vehicles (
  vin, plate, make, model, year, branch_id,
  odometer_km, status, current_tire_type,
  tire_notes, notes
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
    'Winter tires: Michelin X-Ice LT265/70R17. Summer tires: Michelin LT265/70R17.',
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
    'Winter tires: Goodyear Winter LT265/70R17. Summer tires: Goodyear LT265/70R17.',
    'Fleet truck #2 - Primary work vehicle'
  ),
  (
    '1FTFW1ET5DFA34569',
    'Ford',
    'F-150',
    'CVB 001',
    2022,
    (SELECT id FROM branches WHERE name = 'Hamilton Location'),
    89400,
    'active',
    'summer',
    'Winter tires: Bridgestone Blizzak LT265/70R17. Summer tires: Bridgestone LT265/70R17.',
    'Hamilton primary truck'
  ),
  (
    '1FTFW1ET5DFA34570',
    'CVB 002',
    'Ford',
    'F-150',
    2020,
    (SELECT id FROM branches WHERE name = 'Hamilton Location'),
    156700,
    'maintenance',
    'summer',
    'Winter tires: Continental Winter LT265/70R17. Summer tires: Continental LT265/70R17.',
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
    'All-season tires: Michelin 225/65R16',
    'Service van - HVAC and plumbing supplies'
  ),
  (
    '3A3EW5H98ES000002',
    'CVC 002',
    'RAM',
    'ProMaster',
    2023,
    (SELECT id FROM branches WHERE name = 'Mississauga Location'),
    61200,
    'active',
    'all_season',
    'All-season tires: Goodyear 225/65R16',
    'Mississauga service vehicle'
  ),
  (
    '3A3EW5H98ES000003',
    'CVD 001',
    'RAM',
    'ProMaster',
    2022,
    (SELECT id FROM branches WHERE name = 'Hamilton Location'),
    94600,
    'active',
    'all_season',
    'All-season tires: Bridgestone 225/65R16',
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
    'Winter tires: Goodyear 225/65R16C. Summer tires: Goodyear 225/65R16C.',
    'Commercial delivery van'
  ),
  (
    '1GAHG39N63E155079',
    'CVE 002',
    'Chevrolet',
    'Express',
    2022,
    (SELECT id FROM branches WHERE name = 'Mississauga Location'),
    78300,
    'active',
    'summer',
    'Winter tires: Continental 225/65R16C. Summer tires: Continental 225/65R16C.',
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
    'Winter tires: Michelin Winter 215/55R17. Summer tires: Michelin 215/55R17.',
    'Executive company car'
  ),
  (
    '4T1BF1AK7CU123457',
    'CVF 002',
    'Toyota',
    'Camry',
    2021,
    (SELECT id FROM branches WHERE name = 'Mississauga Location'),
    56800,
    'active',
    'summer',
    'Winter tires: Bridgestone Winter 215/55R17. Summer tires: Bridgestone 215/55R17.',
    'Management pool vehicle'
  ),

-- Ford Transit Connect (2)
  (
    '1FTYE1CM3CFA00123',
    'CVG 001',
    'Ford',
    'Transit Connect',
    2023,
    (SELECT id FROM branches WHERE name = 'Hamilton Location'),
    19400,
    'active',
    'all_season',
    'All-season tires: Goodyear 215/60R16',
    'Small commercial van'
  ),
  (
    '1FTYE1CM3CFA00124',
    'CVG 002',
    'Ford',
    'Transit Connect',
    2022,
    (SELECT id FROM branches WHERE name = 'Mississauga Location'),
    45600,
    'active',
    'all_season',
    'All-season tires: Michelin 215/60R16',
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
    'Winter tires: Goodyear Winter LT285/75R16. Summer tires: Goodyear LT285/75R16.',
    'Heavy duty towing truck'
  ),
  (
    '1GT02VE30FZ103457',
    'CVH 002',
    'GMC',
    'Sierra',
    2021,
    (SELECT id FROM branches WHERE name = 'Hamilton Location'),
    126500,
    'active',
    'winter',
    'Winter tires: Bridgestone Winter LT285/75R16. Summer tires: Bridgestone LT285/75R16.',
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
    'Winter tires: Michelin Winter 225/65R17. Summer tires: Michelin 225/65R17.',
    'Manager vehicle - site supervisor'
  ),

-- Hyundai Tucson (1)
  (
    'KM8J3AA46EU123456',
    'CVJ 001',
    'Hyundai',
    'Tucson',
    2023,
    (SELECT id FROM branches WHERE name = 'Mississauga Location'),
    31500,
    'active',
    'all_season',
    'All-season tires: Bridgestone 225/65R17',
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
    'Winter tires: Michelin Winter 225/40R18. Summer tires: Michelin 225/40R18.',
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
    'Winter tires: Goodyear 245/65R17. Summer tires: Goodyear 245/65R17.',
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
  odometer_reading, description, approval_status
)
VALUES
  (
    (SELECT id FROM vehicles WHERE plate = 'CVA 001'),
    (SELECT id FROM expense_categories WHERE name = 'Oil Change'),
    105.39,
    '2025-10-02',
    15200,
    'Synthetic 5W-30 oil change and filter - Jiffy Lube - Marcus Thompson'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVA 002'),
    (SELECT id FROM expense_categories WHERE name = 'Oil Change'),
    98.46,
    '2025-10-05',
    52300,
    'Oil change with fluid top-up - Mr. Lube - James Chen'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVB 001'),
    (SELECT id FROM expense_categories WHERE name = 'Oil Change'),
    112.50,
    '2025-10-08',
    89400,
    'Heavy truck synthetic oil change - Canadian Tire Auto - Robert Walsh'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVB 002'),
    (SELECT id FROM expense_categories WHERE name = 'Oil Change'),
    115.63,
    '2025-10-12',
    156700,
    'Synthetic oil change and inspection - Mr. Lube - Sarah Martinez'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVC 001'),
    (SELECT id FROM expense_categories WHERE name = 'Oil Change'),
    89.05,
    '2025-10-03',
    28400,
    'Van oil change - Jiffy Lube - Lisa Gordon'
  ),

-- Tire Replacements (October)
  (
    (SELECT id FROM vehicles WHERE plate = 'CVE 001'),
    (SELECT id FROM expense_categories WHERE name = 'Tire Replacement'),
    985.38,
    '2025-10-10',
    42100,
    'Set of 4 Goodyear tires with installation and balancing - Costco Tire Centre - David Kumar'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVF 001'),
    (SELECT id FROM expense_categories WHERE name = 'Tire Replacement'),
    645.62,
    '2025-10-15',
    34500,
    'Set of 4 Michelin tires - sedan - Canadian Tire Auto - Michael Brown'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVG 001'),
    (SELECT id FROM expense_categories WHERE name = 'Tire Replacement'),
    712.94,
    '2025-10-18',
    19400,
    'Commercial van tires - 4 tires - Costco Tire Centre - Patricia Wong'
  ),

-- Brake Service (October)
  (
    (SELECT id FROM vehicles WHERE plate = 'CVH 001'),
    (SELECT id FROM expense_categories WHERE name = 'Brake Service'),
    628.32,
    '2025-10-20',
    38900,
    'Front brake pads and rotor replacement - Canadian Tire Auto - Anthony Russo'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVB 001'),
    (SELECT id FROM expense_categories WHERE name = 'Brake Service'),
    753.92,
    '2025-10-22',
    89400,
    'Heavy truck brake service - all 4 wheels - Mr. Lube - Jennifer Hayes'
  ),

-- Air Filter (October)
  (
    (SELECT id FROM vehicles WHERE plate = 'CVF 002'),
    (SELECT id FROM expense_categories WHERE name = 'Air Filter'),
    156.45,
    '2025-10-07',
    56800,
    'Engine air filter replacement - Jiffy Lube - Kevin Patterson'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVC 002'),
    (SELECT id FROM expense_categories WHERE name = 'Air Filter'),
    172.66,
    '2025-10-14',
    61200,
    'Van air filter replacement - Canadian Tire Auto - Amanda Foster'
  ),

-- Transmission Repair (October)
  (
    (SELECT id FROM vehicles WHERE plate = 'CVB 002'),
    (SELECT id FROM expense_categories WHERE name = 'Transmission Repair'),
    1850.00,
    '2025-10-25',
    156700,
    'Transmission fluid flush and filter change - Canadian Tire Auto - Thomas Bell'
  ),

-- Engine Repair (October)
  (
    (SELECT id FROM vehicles WHERE plate = 'CVA 002'),
    (SELECT id FROM expense_categories WHERE name = 'Engine Repair'),
    425.50,
    '2025-10-28',
    52300,
    'Engine knock diagnosis and sensor replacement - Mr. Lube - Nicole Sanders',
    'pending'
  ),

-- Suspension Repair (October)
  (
    (SELECT id FROM vehicles WHERE plate = 'CVH 002'),
    (SELECT id FROM expense_categories WHERE name = 'Suspension Repair'),
    892.15,
    '2025-10-30',
    126500,
    'Front suspension repair and alignment - Canadian Tire Auto - Mark Johnson'
  ),

-- Electrical Repair (October)
  (
    (SELECT id FROM vehicles WHERE plate = 'CVI 001'),
    (SELECT id FROM expense_categories WHERE name = 'Electrical Repair'),
    445.75,
    '2025-10-11',
    47200,
    'Battery replacement and electrical diagnostics - Jiffy Lube - Rebecca Kim'
  );

-- November 2025 expenses (30 expenses)

-- Oil Changes (November)
INSERT INTO expenses (
  vehicle_id, category_id, amount, date,
  odometer_reading, description, approval_status
)
VALUES
  (
    (SELECT id FROM vehicles WHERE plate = 'CVA 001'),
    (SELECT id FROM expense_categories WHERE name = 'Oil Change'),
    105.39,
    '2025-11-02',
    16100,
    'Synthetic 5W-30 oil change and filter - Jiffy Lube - Marcus Thompson'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVA 002'),
    (SELECT id FROM expense_categories WHERE name = 'Oil Change'),
    98.46,
    '2025-11-05',
    53200,
    'Oil change with fluid top-up - Mr. Lube - James Chen'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVB 001'),
    (SELECT id FROM expense_categories WHERE name = 'Oil Change'),
    112.50,
    '2025-11-08',
    90300,
    'Heavy truck synthetic oil change - Canadian Tire Auto - Robert Walsh'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVC 002'),
    (SELECT id FROM expense_categories WHERE name = 'Oil Change'),
    89.05,
    '2025-11-03',
    62100,
    'Van oil change - Jiffy Lube - Lisa Gordon'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVF 001'),
    (SELECT id FROM expense_categories WHERE name = 'Oil Change'),
    95.30,
    '2025-11-10',
    35400,
    'Synthetic oil change - Mr. Lube - Angela Mitchell'
  ),

-- Brake Service (November)
  (
    (SELECT id FROM vehicles WHERE plate = 'CVE 001'),
    (SELECT id FROM expense_categories WHERE name = 'Brake Service'),
    518.75,
    '2025-11-15',
    43000,
    'Rear brake pad replacement - Canadian Tire Auto - David Miller'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVG 002'),
    (SELECT id FROM expense_categories WHERE name = 'Brake Service'),
    445.20,
    '2025-11-18',
    46500,
    'Full brake service and inspection - Mr. Lube - Christina Patel'
  ),

-- Air Filter (November)
  (
    (SELECT id FROM vehicles WHERE plate = 'CVF 002'),
    (SELECT id FROM expense_categories WHERE name = 'Air Filter'),
    156.45,
    '2025-11-07',
    57700,
    'Engine and cabin air filter replacement - Jiffy Lube - Kevin Patterson'
  ),

-- Tire Replacements (November)
  (
    (SELECT id FROM vehicles WHERE plate = 'CVH 001'),
    (SELECT id FROM expense_categories WHERE name = 'Tire Replacement'),
    1125.68,
    '2025-11-20',
    39800,
    'Set of 4 winter tires with installation - Costco Tire Centre - Patricia Wong'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVJ 001'),
    (SELECT id FROM expense_categories WHERE name = 'Tire Replacement'),
    856.42,
    '2025-11-22',
    32400,
    'Set of 4 winter tires - Bridgestone - Canadian Tire Auto - Michael Brown'
  ),

-- Suspension Repair (November)
  (
    (SELECT id FROM vehicles WHERE plate = 'CVB 002'),
    (SELECT id FROM expense_categories WHERE name = 'Suspension Repair'),
    675.30,
    '2025-11-25',
    157600,
    'Rear suspension inspection and repair - Mr. Lube - Mark Johnson'
  ),

-- Electrical Repair (November)
  (
    (SELECT id FROM vehicles WHERE plate = 'CVE 002'),
    (SELECT id FROM expense_categories WHERE name = 'Electrical Repair'),
    325.85,
    '2025-11-12',
    79200,
    'Alternator replacement - Canadian Tire Auto - Rebecca Kim'
  ),

-- Transmission Repair (November)
  (
    (SELECT id FROM vehicles WHERE plate = 'CVA 002'),
    (SELECT id FROM expense_categories WHERE name = 'Transmission Repair'),
    425.50,
    '2025-11-28',
    54100,
    'Transmission fluid check and top-up - Jiffy Lube - Thomas Bell'
  ),

-- Engine Repair (November)
  (
    (SELECT id FROM vehicles WHERE plate = 'CVD 001'),
    (SELECT id FROM expense_categories WHERE name = 'Engine Repair'),
    550.25,
    '2025-11-19',
    95500,
    'Spark plug replacement and ignition system check - Mr. Lube - Nicole Sanders'
  );

-- December 2025 expenses (35 expenses)

-- Oil Changes (December)
INSERT INTO expenses (
  vehicle_id, category_id, amount, date,
  odometer_reading, description, approval_status
)
VALUES
  (
    (SELECT id FROM vehicles WHERE plate = 'CVA 001'),
    (SELECT id FROM expense_categories WHERE name = 'Oil Change'),
    105.39,
    '2025-12-02',
    16900,
    'Synthetic 5W-30 oil change and filter - Jiffy Lube - Marcus Thompson'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVB 001'),
    (SELECT id FROM expense_categories WHERE name = 'Oil Change'),
    112.50,
    '2025-12-08',
    91200,
    'Heavy truck synthetic oil change - Canadian Tire Auto - Robert Walsh'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVG 001'),
    (SELECT id FROM expense_categories WHERE name = 'Oil Change'),
    89.05,
    '2025-12-03',
    20300,
    'Van oil change - Jiffy Lube - Lisa Gordon'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVF 001'),
    (SELECT id FROM expense_categories WHERE name = 'Oil Change'),
    95.30,
    '2025-12-10',
    36300,
    'Synthetic oil change - Mr. Lube - Angela Mitchell'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVC 001'),
    (SELECT id FROM expense_categories WHERE name = 'Oil Change'),
    89.05,
    '2025-12-05',
    29300,
    'Van oil change - Canadian Tire Auto - Lisa Gordon'
  ),

-- Brake Service (December)
  (
    (SELECT id FROM vehicles WHERE plate = 'CVH 002'),
    (SELECT id FROM expense_categories WHERE name = 'Brake Service'),
    628.32,
    '2025-12-15',
    127400,
    'Front brake pads and rotor replacement - Canadian Tire Auto - Anthony Russo'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVC 002'),
    (SELECT id FROM expense_categories WHERE name = 'Brake Service'),
    445.20,
    '2025-12-18',
    62000,
    'Brake fluid flush and pad inspection - Mr. Lube - Christina Patel'
  ),

-- Air Filter (December)
  (
    (SELECT id FROM vehicles WHERE plate = 'CVA 002'),
    (SELECT id FROM expense_categories WHERE name = 'Air Filter'),
    156.45,
    '2025-12-07',
    54000,
    'Engine air filter replacement - Jiffy Lube - Kevin Patterson'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVE 001'),
    (SELECT id FROM expense_categories WHERE name = 'Air Filter'),
    172.66,
    '2025-12-14',
    43900,
    'Van air filter replacement - Canadian Tire Auto - Amanda Foster'
  ),

-- Tire Replacements (December)
  (
    (SELECT id FROM vehicles WHERE plate = 'CVF 001'),
    (SELECT id FROM expense_categories WHERE name = 'Tire Replacement'),
    734.85,
    '2025-12-20',
    37200,
    'Set of 4 winter tires - Michelin - Costco Tire Centre - Patricia Wong'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVI 001'),
    (SELECT id FROM expense_categories WHERE name = 'Tire Replacement'),
    645.62,
    '2025-12-22',
    48100,
    'Set of 4 winter tires - Michelin - Canadian Tire Auto - Michael Brown'
  ),

-- Suspension Repair (December)
  (
    (SELECT id FROM vehicles WHERE plate = 'CVG 002'),
    (SELECT id FROM expense_categories WHERE name = 'Suspension Repair'),
    892.15,
    '2025-12-25',
    46400,
    'Winter suspension inspection and adjustment - Mr. Lube - Mark Johnson'
  ),

-- Electrical Repair (December)
  (
    (SELECT id FROM vehicles WHERE plate = 'CVK 001'),
    (SELECT id FROM expense_categories WHERE name = 'Electrical Repair'),
    365.40,
    '2025-12-12',
    9800,
    'Battery diagnostic and charging system test - Canadian Tire Auto - Rebecca Kim'
  ),

-- Transmission Repair (December)
  (
    (SELECT id FROM vehicles WHERE plate = 'CVB 001'),
    (SELECT id FROM expense_categories WHERE name = 'Transmission Repair'),
    625.75,
    '2025-12-28',
    92100,
    'Transmission fluid flush and filter replacement - Jiffy Lube - Thomas Bell'
  ),

-- Engine Repair (December)
  (
    (SELECT id FROM vehicles WHERE plate = 'CVL 001'),
    (SELECT id FROM expense_categories WHERE name = 'Engine Repair'),
    425.50,
    '2025-12-19',
    179800,
    'Engine coolant flush - archived vehicle - Mr. Lube - Nicole Sanders'
  );

-- January 2026 expenses (30 expenses)

-- Oil Changes (January)
INSERT INTO expenses (
  vehicle_id, category_id, amount, date,
  odometer_reading, description, approval_status
)
VALUES
  (
    (SELECT id FROM vehicles WHERE plate = 'CVA 001'),
    (SELECT id FROM expense_categories WHERE name = 'Oil Change'),
    105.39,
    '2026-01-02',
    17800,
    'Synthetic 5W-30 oil change and filter - Jiffy Lube - Marcus Thompson'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVA 002'),
    (SELECT id FROM expense_categories WHERE name = 'Oil Change'),
    98.46,
    '2026-01-05',
    55000,
    'Oil change with fluid top-up - Mr. Lube - James Chen'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVB 001'),
    (SELECT id FROM expense_categories WHERE name = 'Oil Change'),
    112.50,
    '2026-01-08',
    92100,
    'Heavy truck synthetic oil change - Canadian Tire Auto - Robert Walsh'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVB 002'),
    (SELECT id FROM expense_categories WHERE name = 'Oil Change'),
    115.63,
    '2026-01-12',
    158500,
    'Synthetic oil change and inspection - Mr. Lube - Sarah Martinez'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVC 002'),
    (SELECT id FROM expense_categories WHERE name = 'Oil Change'),
    89.05,
    '2026-01-03',
    63000,
    'Van oil change - Jiffy Lube - Lisa Gordon'
  ),

-- Brake Service (January)
  (
    (SELECT id FROM vehicles WHERE plate = 'CVF 002'),
    (SELECT id FROM expense_categories WHERE name = 'Brake Service'),
    518.75,
    '2026-01-15',
    57600,
    'Winter brake inspection and adjustment - Canadian Tire Auto - David Miller'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVH 001'),
    (SELECT id FROM expense_categories WHERE name = 'Brake Service'),
    628.32,
    '2026-01-18',
    40700,
    'Front brake pads replacement - Mr. Lube - Christina Patel'
  ),

-- Air Filter (January)
  (
    (SELECT id FROM vehicles WHERE plate = 'CVG 001'),
    (SELECT id FROM expense_categories WHERE name = 'Air Filter'),
    156.45,
    '2026-01-07',
    21200,
    'Engine air filter replacement - Jiffy Lube - Kevin Patterson'
  ),

-- Tire service (January) - winter tire checks
  (
    (SELECT id FROM vehicles WHERE plate = 'CVJ 001'),
    (SELECT id FROM expense_categories WHERE name = 'Tire Replacement'),
    125.85,
    '2026-01-20',
    33300,
    'Tire rotation and winter inspection - Costco Tire Centre - Patricia Wong'
  ),

-- Suspension Repair (January)
  (
    (SELECT id FROM vehicles WHERE plate = 'CVE 002'),
    (SELECT id FROM expense_categories WHERE name = 'Suspension Repair'),
    745.20,
    '2026-01-25',
    79100,
    'Suspension alignment and repair - Mr. Lube - Mark Johnson'
  ),

-- Electrical Repair (January)
  (
    (SELECT id FROM vehicles WHERE plate = 'CVD 001'),
    (SELECT id FROM expense_categories WHERE name = 'Electrical Repair'),
    325.85,
    '2026-01-12',
    96400,
    'Alternator and battery check - Canadian Tire Auto - Rebecca Kim'
  ),

-- Engine Repair (January)
  (
    (SELECT id FROM vehicles WHERE plate = 'CVE 001'),
    (SELECT id FROM expense_categories WHERE name = 'Engine Repair'),
    425.50,
    '2026-01-19',
    44800,
    'Spark plug replacement - Jiffy Lube - Nicole Sanders'
  );

-- February 2026 expenses (25 expenses)

-- Oil Changes (February)
INSERT INTO expenses (
  vehicle_id, category_id, amount, date,
  odometer_reading, description, approval_status
)
VALUES
  (
    (SELECT id FROM vehicles WHERE plate = 'CVA 001'),
    (SELECT id FROM expense_categories WHERE name = 'Oil Change'),
    105.39,
    '2026-02-02',
    18700,
    'Synthetic 5W-30 oil change and filter - Jiffy Lube - Marcus Thompson'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVF 001'),
    (SELECT id FROM expense_categories WHERE name = 'Oil Change'),
    95.30,
    '2026-02-10',
    38200,
    'Synthetic oil change - Mr. Lube - Angela Mitchell'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVG 002'),
    (SELECT id FROM expense_categories WHERE name = 'Oil Change'),
    89.05,
    '2026-02-05',
    47500,
    'Van oil change - Canadian Tire Auto - Lisa Gordon'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVC 001'),
    (SELECT id FROM expense_categories WHERE name = 'Oil Change'),
    89.05,
    '2026-02-03',
    30200,
    'Van oil change - Jiffy Lube - Lisa Gordon'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVH 002'),
    (SELECT id FROM expense_categories WHERE name = 'Oil Change'),
    112.50,
    '2026-02-08',
    128300,
    'Heavy truck synthetic oil change - Canadian Tire Auto - Robert Walsh'
  ),

-- Brake Service (February)
  (
    (SELECT id FROM vehicles WHERE plate = 'CVI 001'),
    (SELECT id FROM expense_categories WHERE name = 'Brake Service'),
    445.20,
    '2026-02-15',
    48900,
    'Brake fluid flush and pad check - Mr. Lube - Christina Patel'
  ),

-- Air Filter (February)
  (
    (SELECT id FROM vehicles WHERE plate = 'CVK 001'),
    (SELECT id FROM expense_categories WHERE name = 'Air Filter'),
    156.45,
    '2026-02-07',
    10700,
    'Engine air filter replacement - Jiffy Lube - Kevin Patterson'
  ),

-- Tire service (February)
  (
    (SELECT id FROM vehicles WHERE plate = 'CVA 002'),
    (SELECT id FROM expense_categories WHERE name = 'Tire Replacement'),
    125.85,
    '2026-02-20',
    55900,
    'Tire rotation and balance - Costco Tire Centre - Patricia Wong'
  ),

-- Electrical Repair (February)
  (
    (SELECT id FROM vehicles WHERE plate = 'CVB 001'),
    (SELECT id FROM expense_categories WHERE name = 'Electrical Repair'),
    365.40,
    '2026-02-12',
    93000,
    'Battery replacement and diagnostics - Canadian Tire Auto - Rebecca Kim'
  ),

-- Transmission Repair (February)
  (
    (SELECT id FROM vehicles WHERE plate = 'CVG 001'),
    (SELECT id FROM expense_categories WHERE name = 'Transmission Repair'),
    425.50,
    '2026-02-28',
    22100,
    'Transmission fluid level check and top-up - Mr. Lube - Thomas Bell'
  );

-- March 2026 expenses (20 expenses)

-- Oil Changes (March)
INSERT INTO expenses (
  vehicle_id, category_id, amount, date,
  odometer_reading, description, approval_status
)
VALUES
  (
    (SELECT id FROM vehicles WHERE plate = 'CVA 001'),
    (SELECT id FROM expense_categories WHERE name = 'Oil Change'),
    105.39,
    '2026-03-02',
    19600,
    'Synthetic 5W-30 oil change and filter - Jiffy Lube - Marcus Thompson'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVB 001'),
    (SELECT id FROM expense_categories WHERE name = 'Oil Change'),
    112.50,
    '2026-03-08',
    93900,
    'Heavy truck synthetic oil change - Canadian Tire Auto - Robert Walsh'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVF 001'),
    (SELECT id FROM expense_categories WHERE name = 'Oil Change'),
    95.30,
    '2026-03-10',
    39100,
    'Synthetic oil change - Mr. Lube - Angela Mitchell'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVC 002'),
    (SELECT id FROM expense_categories WHERE name = 'Oil Change'),
    89.05,
    '2026-03-03',
    64000,
    'Van oil change - Canadian Tire Auto - Lisa Gordon'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVJ 001'),
    (SELECT id FROM expense_categories WHERE name = 'Oil Change'),
    95.30,
    '2026-03-05',
    34200,
    'Oil change - Jiffy Lube - Angela Mitchell'
  ),

-- Brake Service (March)
  (
    (SELECT id FROM vehicles WHERE plate = 'CVE 001'),
    (SELECT id FROM expense_categories WHERE name = 'Brake Service'),
    518.75,
    '2026-03-15',
    45700,
    'Spring brake inspection and service - Canadian Tire Auto - David Miller'
  ),

-- Tire service (March) - spring tire changeover prep
  (
    (SELECT id FROM vehicles WHERE plate = 'CVH 001'),
    (SELECT id FROM expense_categories WHERE name = 'Tire Replacement'),
    125.85,
    '2026-03-20',
    41600,
    'Spring tire changeover preparation - Costco Tire Centre - Patricia Wong'
  ),

-- Air Filter (March)
  (
    (SELECT id FROM vehicles WHERE plate = 'CVE 002'),
    (SELECT id FROM expense_categories WHERE name = 'Air Filter'),
    172.66,
    '2026-03-07',
    80000,
    'Van air filter replacement - Canadian Tire Auto - Amanda Foster'
  ),

-- Suspension Repair (March)
  (
    (SELECT id FROM vehicles WHERE plate = 'CVI 001'),
    (SELECT id FROM expense_categories WHERE name = 'Suspension Repair'),
    625.75,
    '2026-03-25',
    49800,
    'Spring suspension inspection and repair - Mr. Lube - Mark Johnson'
  ),

-- Engine Repair (March)
  (
    (SELECT id FROM vehicles WHERE plate = 'CVA 002'),
    (SELECT id FROM expense_categories WHERE name = 'Engine Repair'),
    425.50,
    '2026-03-19',
    56800,
    'Spring engine maintenance - coolant flush - Jiffy Lube - Nicole Sanders'
  );

-- ============================================================
-- 4. TIRE CHANGES (Track tire swaps throughout the season)
-- ============================================================

INSERT INTO tire_changes (
  vehicle_id, branch_id, tire_type, current_tire_type,
  change_date, summer_tire_location, winter_tire_location, notes
)
VALUES
  (
    (SELECT id FROM vehicles WHERE plate = 'CVA 001'),
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    'winter',
    'winter',
    '2025-11-01',
    'Storage Room B',
    'Mounted on vehicle',
    'Fall changeover - switched to winter tires'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVA 002'),
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    'winter',
    'winter',
    '2025-11-01',
    'Storage Room B',
    'Mounted on vehicle',
    'Fall changeover - switched to winter tires'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVB 001'),
    (SELECT id FROM branches WHERE name = 'Hamilton Location'),
    'summer',
    'summer',
    '2025-10-15',
    'Mounted on vehicle',
    'Storage Garage B',
    'Maintained summer tires through fall'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVE 001'),
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    'summer',
    'summer',
    '2025-10-10',
    'Mounted on vehicle',
    'N/A',
    'Tire replacement - new summer tires installed'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVF 001'),
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    'winter',
    'winter',
    '2025-11-15',
    'Storage Room B',
    'Mounted on vehicle',
    'Switched to winter tires Michelin'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVH 001'),
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    'winter',
    'winter',
    '2025-11-20',
    'Storage Garage A',
    'Mounted on vehicle',
    'Winter tire changeover - heavy duty truck'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVJ 001'),
    (SELECT id FROM branches WHERE name = 'Mississauga Location'),
    'winter',
    'winter',
    '2025-11-22',
    'Storage Room A',
    'Mounted on vehicle',
    'Switched to winter tires - Bridgestone'
  );

-- ============================================================
-- 5. VEHICLE INSPECTIONS (Monthly inspections for fleet)
-- ============================================================

INSERT INTO vehicle_inspections (
  vehicle_id, branch_id, inspection_date, inspection_month, kilometers,
  brakes_pass, brakes_notes,
  engine_pass, engine_notes,
  transmission_pass, transmission_notes,
  tires_pass, tires_notes,
  headlights_pass, headlights_notes,
  signal_lights_pass, signal_lights_notes,
  oil_level_pass, oil_level_notes,
  windshield_fluid_pass, windshield_fluid_notes,
  wipers_pass, wipers_notes
)
VALUES
  (
    (SELECT id FROM vehicles WHERE plate = 'CVA 001'),
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    '2025-10-15',
    '2025-10-01'::date,
    15200,
    true, 'Brakes in good condition, pads at 70%',
    true, 'Engine running smoothly',
    true, 'Transmission fluid clean',
    true, 'Winter tires - tread at 6mm',
    true, 'Headlights working properly',
    true, 'All signal lights functioning',
    true, 'Oil level normal',
    true, 'Windshield fluid at 75%',
    true, 'Wipers in good condition'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVA 002'),
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    '2025-10-20',
    '2025-10-01'::date,
    52300,
    true, 'Front pads at 60%, rears at 75%',
    true, 'Engine running well, no knocking',
    true, 'Transmission fluid dark - changed soon',
    true, 'Winter tires - tread at 5mm',
    false, 'Right headlight dim - replace bulb',
    true, 'All signal lights functioning',
    true, 'Oil level normal',
    true, 'Windshield fluid adequate',
    true, 'Wipers functioning well'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVB 001'),
    (SELECT id FROM branches WHERE name = 'Hamilton Location'),
    '2025-10-22',
    '2025-10-01'::date,
    89400,
    false, 'Rear brake pads worn - recommend replacement',
    true, 'Engine running smoothly',
    true, 'Transmission performing well',
    true, 'Summer tires - tread at 4mm',
    true, 'All headlights functioning',
    true, 'All signal lights working',
    true, 'Oil level normal',
    true, 'Windshield fluid full',
    true, 'Wipers in good condition'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVF 001'),
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    '2025-11-05',
    '2025-11-01'::date,
    35400,
    true, 'Brakes in good condition',
    true, 'Engine running smoothly',
    true, 'Transmission fluid clean',
    true, 'Winter tires freshly installed - tread 8mm',
    true, 'Headlights clear and bright',
    true, 'All signal lights functioning',
    true, 'Oil level normal',
    true, 'Windshield fluid at 80%',
    true, 'Wipers replaced - new condition'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVH 001'),
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    '2025-11-25',
    '2025-11-01'::date,
    40700,
    true, 'Brakes serviced recently - excellent condition',
    true, 'Engine running smoothly',
    true, 'Transmission performing well',
    true, 'Winter tires freshly installed - tread 8.5mm',
    true, 'All headlights functioning',
    true, 'All signal lights working',
    true, 'Oil level normal',
    true, 'Windshield fluid full',
    true, 'Wipers in good condition'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVE 001'),
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    '2025-12-10',
    '2025-12-01'::date,
    44800,
    true, 'Brakes inspected - pads at 65%',
    true, 'Engine running well',
    true, 'Transmission fluid normal',
    true, 'Summer tires with new Goodyears - tread 8mm',
    true, 'All headlights functioning',
    true, 'All signal lights working',
    true, 'Oil level normal',
    true, 'Windshield fluid at 60%',
    true, 'Wipers functioning'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVB 002'),
    (SELECT id FROM branches WHERE name = 'Hamilton Location'),
    '2025-12-15',
    '2025-12-01'::date,
    157600,
    true, 'Brakes repaired recently - good condition',
    true, 'Engine running smoothly',
    true, 'Transmission fluid flushed - excellent',
    true, 'Summer tires - tread at 5mm',
    true, 'All headlights functioning',
    true, 'All signal lights working',
    true, 'Oil level normal',
    true, 'Windshield fluid adequate',
    true, 'Wipers in good condition'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVI 001'),
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    '2026-01-20',
    '2026-01-01'::date,
    49800,
    true, 'Brakes in good condition',
    true, 'Engine running smoothly',
    true, 'Transmission performing well',
    true, 'Winter tires with good tread - 6.5mm',
    true, 'All headlights clear and bright',
    true, 'All signal lights functioning',
    true, 'Oil level normal',
    true, 'Windshield fluid at 70%',
    true, 'Wipers replaced - excellent condition'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVJ 001'),
    (SELECT id FROM branches WHERE name = 'Mississauga Location'),
    '2026-01-25',
    '2026-01-01'::date,
    33300,
    true, 'Brakes inspected - good condition',
    true, 'Engine running well',
    true, 'Transmission fluid normal',
    true, 'Winter tires installed - tread 8mm',
    true, 'All headlights functioning',
    true, 'All signal lights working',
    true, 'Oil level normal',
    true, 'Windshield fluid full',
    true, 'Wipers in good condition'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVA 001'),
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    '2026-02-15',
    '2026-02-01'::date,
    18700,
    true, 'Brakes in good condition',
    true, 'Engine running smoothly',
    true, 'Transmission fluid clean',
    true, 'Winter tires - tread at 5.5mm, good condition',
    true, 'Headlights clear and bright',
    true, 'All signal lights functioning',
    true, 'Oil level normal',
    true, 'Windshield fluid at 75%',
    true, 'Wipers functioning well'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVB 001'),
    (SELECT id FROM branches WHERE name = 'Hamilton Location'),
    '2026-02-20',
    '2026-02-01'::date,
    93900,
    true, 'Brakes in good condition',
    true, 'Engine running smoothly',
    true, 'Transmission performing well',
    true, 'Summer tires - tread at 4.5mm, acceptable',
    true, 'All headlights functioning',
    true, 'All signal lights working',
    true, 'Oil level normal',
    true, 'Windshield fluid adequate',
    true, 'Wipers in good condition'
  ),
  (
    (SELECT id FROM vehicles WHERE plate = 'CVE 001'),
    (SELECT id FROM branches WHERE name = 'Main Office - Toronto'),
    '2026-03-15',
    '2026-03-01'::date,
    46700,
    true, 'Brakes serviced - excellent condition',
    true, 'Engine running smoothly',
    true, 'Transmission fluid normal',
    true, 'Summer tires ready for spring - tread 7.5mm',
    true, 'All headlights functioning',
    true, 'All signal lights working',
    true, 'Oil level normal',
    true, 'Windshield fluid at 80%',
    true, 'Wipers replaced - new condition'
  );

COMMIT;
