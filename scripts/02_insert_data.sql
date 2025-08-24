-- ProtonBase Consolidated Demo Sample Data
-- This script inserts realistic sample data into the consolidated schema
-- The data is designed to showcase ProtonBase's ability to handle multiple data types

-- Insert sample neighborhoods for geospatial queries using PostGIS POLYGON
INSERT INTO property_data.neighborhoods (name, location_polygon)
VALUES 
    ('Downtown Seattle', ST_GeomFromText('POLYGON((-122.3421 47.5962, -122.3321 47.5962, -122.3321 47.6162, -122.3421 47.6162, -122.3421 47.5962))', 4326)),
    ('Capitol Hill', ST_GeomFromText('POLYGON((-122.3221 47.6162, -122.3121 47.6162, -122.3121 47.6262, -122.3221 47.6262, -122.3221 47.6162))', 4326)),
    ('South Lake Union', ST_GeomFromText('POLYGON((-122.3421 47.6262, -122.3321 47.6262, -122.3321 47.6362, -122.3421 47.6362, -122.3421 47.6262))', 4326)),
    ('Ballard', ST_GeomFromText('POLYGON((-122.3821 47.6562, -122.3621 47.6562, -122.3621 47.6762, -122.3821 47.6762, -122.3821 47.6562))', 4326)),
    ('Bellevue Downtown', ST_GeomFromText('POLYGON((-122.2106 47.6101, -122.2006 47.6101, -122.2006 47.6201, -122.2106 47.6201, -122.2106 47.6101))', 4326));

-- Insert sample unified properties with all data types in a single table
INSERT INTO property_data.unified_properties (
    -- Relational data
    title, address, city, state, zip_code, price, bedrooms, bathrooms, 
    square_feet, year_built, property_type, listing_date, status,
    -- JSON data
    amenities, features,
    -- Text data
    description,
    -- Geospatial data
    location_point,
    -- Vector data (384-dimensional, but using simplified vectors for demo)
    embedding
) VALUES
    (
        -- Property 1: Luxury Downtown Condo
        'Luxury Downtown Penthouse', '123 Main St, Apt 1000', 'Seattle', 'WA', '98101', 
        2250000.00, 3, 2.5, 2200, 2018, 'Condo', '2025-01-15', 'Active',
        
        -- JSON amenities
        '{
            "indoor": ["Air Conditioning", "Washer/Dryer", "High-Speed Internet", "Smart Home System", "Wine Cellar"],
            "building": ["24/7 Concierge", "Fitness Center", "Rooftop Deck", "Private Theater", "Wine Room", "Conference Room"],
            "outdoor": ["Balcony", "City Views", "Mountain Views", "Water Views"]
        }',
        
        -- JSON features
        '{
            "interior": {
                "flooring": "Italian Marble",
                "kitchen": {
                    "type": "Gourmet Chef''s Kitchen",
                    "appliances": ["Wolf Range", "Sub-Zero Refrigerator", "Miele Dishwasher", "Wine Refrigerator"],
                    "features": ["Waterfall Island", "Custom Cabinetry", "Quartz Countertops"]
                },
                "windows": "Floor-to-ceiling",
                "ceiling_height": "10 feet",
                "smart_home": {
                    "lighting": true,
                    "climate": true,
                    "security": true,
                    "entertainment": true,
                    "voice_control": true
                }
            },
            "building": {
                "security": "24/7 Doorman",
                "year_built": 2018,
                "total_floors": 40,
                "units_per_floor": 4,
                "construction": "Steel and Glass",
                "architect": "Foster + Partners"
            },
            "utilities": {
                "heating": "Radiant Floor",
                "cooling": "Central AC",
                "water_heater": "Tankless",
                "energy_efficiency": "LEED Platinum"
            },
            "parking": {
                "type": "Private Garage",
                "spaces": 2,
                "valet": true,
                "ev_charging": true
            }
        }',
        
        -- Text description for full-text search
        'Experience the pinnacle of luxury living in this stunning penthouse located in the heart of downtown Seattle. This extraordinary residence offers breathtaking 270-degree views of the city skyline, Puget Sound, and the Olympic Mountains through walls of floor-to-ceiling windows. The open floor plan features a grand living area with 10-foot ceilings, a gas fireplace with marble surround, and direct access to the expansive wraparound terrace.

The gourmet chef''s kitchen is equipped with top-of-the-line Wolf and Sub-Zero appliances, custom Italian cabinetry, waterfall quartz countertops, and a large center island perfect for entertaining. The primary suite is a true sanctuary with a private balcony, custom walk-in closet, and a spa-like bathroom featuring a freestanding soaking tub, oversized shower, and dual vanities.

Two additional bedrooms, each with en-suite bathrooms, provide comfortable accommodations for family or guests. Additional features include a home office, media room, wine cellar, and smart home technology controlling lighting, climate, security, and entertainment systems.

Building amenities include 24/7 concierge service, valet parking, a state-of-the-art fitness center, rooftop deck with outdoor kitchen, private theater, wine room, and conference facilities. Two private parking spaces and additional storage are included.

Located in the prestigious Infinity Tower, residents enjoy walking distance to Seattle''s finest restaurants, shops, arts venues, and the waterfront. This penthouse represents the ultimate in sophisticated urban living.',
        
        -- Geospatial data (longitude, latitude)
        ST_GeomFromText('POINT(-122.3321 47.6062)',4326)::GEOGRAPHY,
        
        -- Vector embedding (simplified 384-dimensional vector)
        array_fill(0.036::float, ARRAY[384])
    ),
    (
        -- Property 2: Waterfront Luxury Home
        'Waterfront Luxury Estate', '456 Lake Shore Dr', 'Seattle', 'WA', '98105', 
        4500000.00, 5, 4.5, 5800, 2020, 'Single Family', '2025-01-10', 'Active',
        
        -- JSON amenities
        '{
            "indoor": ["Air Conditioning", "Washer/Dryer", "High-Speed Internet", "Smart Home System", "Wine Cellar", "Home Theater", "Gym", "Sauna"],
            "outdoor": ["Private Dock", "Infinity Pool", "Outdoor Kitchen", "Fire Pit", "Landscaped Gardens", "Water Views", "Mountain Views"]
        }',
        
        -- JSON features
        '{
            "interior": {
                "flooring": "Wide Plank Oak",
                "kitchen": {
                    "type": "Professional Chef''s Kitchen",
                    "appliances": ["Wolf Range", "Sub-Zero Refrigerator", "Miele Dishwasher", "Wine Refrigerator", "Warming Drawer", "Steam Oven"],
                    "features": ["Double Islands", "Custom Cabinetry", "Marble Countertops", "Butler''s Pantry"]
                },
                "windows": "Floor-to-ceiling",
                "ceiling_height": "12 feet",
                "smart_home": {
                    "lighting": true,
                    "climate": true,
                    "security": true,
                    "entertainment": true,
                    "voice_control": true,
                    "window_treatments": true
                }
            },
            "exterior": {
                "construction": "Stone and Glass",
                "architect": "Olson Kundig",
                "roof": "Slate",
                "waterfront": {
                    "type": "Lake",
                    "frontage": "100 feet",
                    "dock": true,
                    "boat_lift": true
                }
            },
            "utilities": {
                "heating": "Radiant Floor",
                "cooling": "Central AC",
                "water_heater": "Tankless",
                "energy_efficiency": "LEED Gold",
                "solar_panels": true
            },
            "parking": {
                "type": "Attached Garage",
                "spaces": 4,
                "ev_charging": true
            }
        }',
        
        -- Text description for full-text search
        'Discover unparalleled waterfront luxury in this magnificent estate on Lake Washington. This architectural masterpiece, designed by renowned architect Olson Kundig, offers an exceptional indoor-outdoor living experience with breathtaking views of the lake, mountains, and Seattle skyline.

The grand entrance welcomes you with soaring 12-foot ceilings, walls of glass, and a floating staircase. The main level features a stunning great room with a linear gas fireplace, formal dining area, and a professional chef''s kitchen equipped with top-of-the-line Wolf and Sub-Zero appliances, double islands, custom cabinetry, and a butler''s pantry.

The primary suite is a true retreat with lake views, a private deck, dual walk-in closets, and a spa-inspired bathroom featuring a freestanding soaking tub, oversized steam shower, and heated floors. Four additional en-suite bedrooms provide luxurious accommodations for family and guests.

Additional interior spaces include a home office, media room, wine cellar, gym, sauna, and a lower-level entertainment area with a full bar. The smart home system controls lighting, climate, security, entertainment, and motorized window treatments throughout the residence.

The outdoor oasis showcases an infinity pool that appears to merge with the lake, an outdoor kitchen, fire pit, and meticulously landscaped gardens. The private dock with boat lift provides direct access to Lake Washington.

This extraordinary property offers the perfect blend of sophisticated design, luxurious amenities, and a premier waterfront location just minutes from downtown Seattle.',
        
        -- Geospatial data (longitude, latitude)
        ST_GeomFromText('POINT(-122.2559 47.6371)',4326)::GEOGRAPHY,
        
        -- Vector embedding (simplified 384-dimensional vector)
       array_fill(0.042::float, ARRAY[384])
    ),
    (
        -- Property 3: Modern Tech Hub Loft
        'Modern Tech Hub Loft', '789 Innovation Way', 'Seattle', 'WA', '98109', 
        1250000.00, 2, 2.0, 1800, 2019, 'Loft', '2025-01-18', 'Active',
        
        -- JSON amenities
        '{
            "indoor": ["Air Conditioning", "Washer/Dryer", "Gigabit Internet", "Smart Home System", "EV Charging"],
            "building": ["24/7 Security", "Coworking Space", "Fitness Center", "Rooftop Lounge", "Package Lockers", "Bike Storage"],
            "outdoor": ["Balcony", "City Views", "Rooftop Garden"]
        }',
        
        -- JSON features
        '{
            "interior": {
                "flooring": "Polished Concrete",
                "kitchen": {
                    "type": "Modern Open Kitchen",
                    "appliances": ["Bosch Range", "Samsung Smart Refrigerator", "Bosch Dishwasher", "Wine Refrigerator"],
                    "features": ["Waterfall Island", "Quartz Countertops", "Custom Lighting"]
                },
                "windows": "Floor-to-ceiling",
                "ceiling_height": "14 feet",
                "smart_home": {
                    "lighting": true,
                    "climate": true,
                    "security": true,
                    "entertainment": true,
                    "voice_control": true,
                    "work_from_home": {
                        "dedicated_office": true,
                        "video_conferencing": true,
                        "sound_proofing": true,
                        "ergonomic_setup": true
                    }
                }
            },
            "building": {
                "security": "Keyless Entry",
                "year_built": 2019,
                "total_floors": 12,
                "units_per_floor": 8,
                "construction": "Industrial Modern",
                "tech_amenities": ["Building-wide Mesh WiFi", "Smart Package Room", "EV Charging", "Digital Concierge"]
            },
            "utilities": {
                "heating": "Forced Air",
                "cooling": "Central AC",
                "water_heater": "Tankless",
                "energy_efficiency": "Energy Star",
                "smart_metering": true
            },
            "parking": {
                "type": "Underground Garage",
                "spaces": 1,
                "ev_charging": true
            }
        }',
        
        -- Text description for full-text search
        'Welcome to the ultimate tech-forward urban living experience in this stunning loft located in Seattle''s Innovation District. This modern residence combines industrial chic design with cutting-edge smart home technology, creating the perfect environment for today''s tech professionals.

The open-concept living space features soaring 14-foot ceilings, polished concrete floors, and walls of windows that flood the space with natural light and showcase panoramic city views. The modern kitchen is equipped with high-end Bosch appliances, including a Samsung smart refrigerator, quartz countertops, and a waterfall island perfect for both entertaining and casual dining.

The primary bedroom offers a custom-designed walk-in closet and an en-suite bathroom with a rainfall shower and floating vanity. The second bedroom has been transformed into a state-of-the-art home office with soundproofing, built-in ergonomic workstation, and professional video conferencing setup.

This smart home features integrated systems controlling lighting, climate, security, and entertainment, all accessible via voice commands or smartphone. The gigabit internet connection ensures seamless connectivity for remote work and streaming.

Building amenities include a coworking space with private meeting rooms, a state-of-the-art fitness center, rooftop lounge with outdoor kitchen, and secure bike storage. The tech-forward building also offers EV charging stations, a smart package room, and building-wide mesh WiFi.

Located in the heart of Seattle''s Innovation District, this loft is within walking distance to major tech companies, trendy restaurants, artisanal coffee shops, and public transportation. This is urban living redesigned for the modern tech professional.',
        
        -- Geospatial data (longitude, latitude)
        ST_GeomFromText('POINT(-122.3493 47.6205)',4326)::GEOGRAPHY,
        
        -- Vector embedding (simplified 384-dimensional vector)
        array_fill(0.039::float, ARRAY[384])
    ),
    (
        -- Property 4: Historic Craftsman Home
        'Restored Historic Craftsman', '321 Heritage Lane', 'Seattle', 'WA', '98112', 
        1850000.00, 4, 3.5, 3200, 1910, 'Single Family', '2025-01-05', 'Active',
        
        -- JSON amenities
        '{
            "indoor": ["Radiant Heat", "Washer/Dryer", "High-Speed Internet", "Original Woodwork", "Wine Cellar"],
            "outdoor": ["Covered Porch", "Landscaped Garden", "Detached Garage", "Mature Trees", "Fire Pit"]
        }',
        
        -- JSON features
        '{
            "interior": {
                "flooring": "Original Hardwood",
                "kitchen": {
                    "type": "Updated Vintage",
                    "appliances": ["Wolf Range", "Sub-Zero Refrigerator", "Miele Dishwasher", "Farmhouse Sink"],
                    "features": ["Custom Cabinetry", "Soapstone Countertops", "Breakfast Nook"]
                },
                "windows": "Original Leaded Glass",
                "ceiling_height": "9 feet",
                "historic_elements": {
                    "woodwork": true,
                    "built_ins": true,
                    "fireplace": true,
                    "stained_glass": true,
                    "pocket_doors": true
                }
            },
            "exterior": {
                "construction": "Craftsman",
                "architect": "Unknown",
                "roof": "Cedar Shake",
                "historic_designation": "Seattle Historic Register"
            },
            "utilities": {
                "heating": "Radiant Floor",
                "cooling": "Mini-Split System",
                "water_heater": "Tankless",
                "energy_efficiency": "Updated Insulation",
                "modern_wiring": true
            },
            "parking": {
                "type": "Detached Garage",
                "spaces": 2,
                "ev_charging": true
            }
        }',
        
        -- Text description for full-text search
        'Step back in time with this meticulously restored 1910 Craftsman home in Seattle''s historic Capitol Hill neighborhood. This architectural gem combines period charm with thoughtful modern updates to create a truly special residence.

The home welcomes you with a classic covered front porch and an entry foyer showcasing original woodwork and a grand staircase. The formal living room features a wood-burning fireplace with the original tile surround, built-in bookshelves, and leaded glass windows. The adjacent formal dining room includes original box beam ceilings, wainscoting, and a stunning built-in china cabinet.

The updated kitchen respects the home''s vintage character while incorporating modern amenities, including a Wolf range, Sub-Zero refrigerator, Miele dishwasher, farmhouse sink, soapstone countertops, and custom cabinetry. A charming breakfast nook with window seat offers views of the garden.

The second floor features a primary suite with a walk-in closet and an en-suite bathroom with a clawfoot tub and separate shower. Three additional bedrooms and two bathrooms complete the upper level. The finished basement includes a family room, wine cellar, and half bathroom.

Modern updates include radiant floor heating, mini-split cooling system, updated electrical and plumbing, and enhanced insulation, all while preserving the home''s historic integrity. The landscaped yard features mature trees, perennial gardens, and a fire pit area for outdoor entertaining. A detached two-car garage includes an EV charging station.

Located in the heart of Capitol Hill, this home is within walking distance to restaurants, shops, parks, and public transportation. This is a rare opportunity to own a piece of Seattle''s architectural history with all the comforts of modern living.',
        
        -- Geospatial data (longitude, latitude)
        ST_GeomFromText('POINT(-122.3125 47.6250)',4326)::GEOGRAPHY,
        
        -- Vector embedding (simplified 384-dimensional vector)
        array_fill(0.033::float, ARRAY[384])
    ),
    (
        -- Property 5: Eco-Friendly Smart Home
        'Sustainable Modern Smart Home', '555 Green Living Way', 'Bellevue', 'WA', '98004', 
        2750000.00, 4, 3.5, 3800, 2023, 'Single Family', '2025-01-20', 'Active',
        
        -- JSON amenities
        '{
            "indoor": ["Geothermal Heating/Cooling", "Washer/Dryer", "Gigabit Internet", "Smart Home System", "Home Battery", "Air Purification"],
            "outdoor": ["Solar Panels", "Rain Collection System", "Native Landscaping", "Outdoor Living Space", "EV Charging", "Green Roof"]
        }',
        
        -- JSON features
        '{
            "interior": {
                "flooring": "Sustainable Bamboo",
                "kitchen": {
                    "type": "Energy Efficient Modern",
                    "appliances": ["Energy Star Induction Range", "Energy Star Refrigerator", "Water-Saving Dishwasher"],
                    "features": ["Recycled Glass Countertops", "Sustainable Cabinetry", "Water Filtration System"]
                },
                "windows": "Triple-Pane Energy Efficient",
                "ceiling_height": "10 feet",
                "smart_home": {
                    "lighting": true,
                    "climate": true,
                    "security": true,
                    "entertainment": true,
                    "voice_control": true,
                    "energy_management": true,
                    "water_management": true
                }
            },
            "exterior": {
                "construction": "Sustainable Materials",
                "architect": "Green Design Architects",
                "roof": "Solar Tiles",
                "insulation": "High-Performance Foam",
                "sustainability_features": {
                    "solar_power": true,
                    "rainwater_harvesting": true,
                    "greywater_system": true,
                    "green_roof": true,
                    "passive_solar_design": true
                }
            },
            "utilities": {
                "heating": "Geothermal",
                "cooling": "Geothermal",
                "water_heater": "Heat Pump",
                "energy_efficiency": "Net Zero",
                "battery_storage": true,
                "smart_metering": true
            },
            "parking": {
                "type": "Attached Garage",
                "spaces": 2,
                "ev_charging": true
            }
        }',
        
        -- Text description for full-text search
        'Welcome to the future of sustainable living in this state-of-the-art smart home in Bellevue. This LEED Platinum-certified residence combines cutting-edge technology with eco-friendly design to create a home that''s as kind to the environment as it is comfortable to live in.

The open-concept main level features sustainable bamboo flooring, soaring 10-foot ceilings, and triple-pane windows that maximize natural light while providing superior insulation. The energy-efficient kitchen includes Energy Star appliances, recycled glass countertops, sustainable cabinetry, and a comprehensive water filtration system.

The primary suite offers a walk-in closet with built-in organization and an en-suite bathroom featuring a water-conserving rainfall shower, dual vanities with low-flow fixtures, and a freestanding tub. Three additional bedrooms and two bathrooms complete the upper level.

This home achieves net-zero energy consumption through an integrated system of solar tiles, geothermal heating and cooling, and Tesla Powerwall battery storage. The comprehensive smart home system manages energy and water usage, lighting, climate control, security, and entertainment, all accessible via voice commands or smartphone.

Outdoor features include a rainwater harvesting system that supplies irrigation for the native, drought-resistant landscaping, a partial green roof that provides insulation and reduces stormwater runoff, and a covered outdoor living space with a built-in kitchen. The attached garage includes dual EV charging stations.

Located in a premier Bellevue neighborhood, this home is close to tech campuses, excellent schools, shopping, dining, and parks. This is more than just a home—it''s a statement about sustainable living without compromise.',
        
        -- Geospatial data (longitude, latitude)
        ST_GeomFromText('POINT(-122.2015 47.6101)',4326)::GEOGRAPHY,
        
        -- Vector embedding (simplified 384-dimensional vector)
       array_fill(0.045::float, ARRAY[384])
    );

-- Print success message
\echo 'Sample data inserted successfully!'
\echo 'The database now contains properties with relational, JSON, text, geospatial, and vector data.'