# Eco-Tourism and Sustainable Travel Services

A comprehensive blockchain-based system for managing sustainable tourism operations, environmental impact monitoring, and community benefit sharing.

## System Overview

This system consists of five interconnected Clarity smart contracts that work together to create a transparent, accountable eco-tourism platform:

### 1. Environmental Impact Monitor (`environmental-impact.clar`)
- Tracks carbon emissions, waste generation, and resource consumption
- Monitors environmental metrics for tourism activities
- Provides impact scoring and threshold management
- Enables transparent environmental reporting

### 2. Carbon Offset Coordinator (`carbon-offset.clar`)
- Manages carbon credit purchases and retirement
- Tracks offset projects and their verification status
- Calculates required offsets based on tourism activities
- Provides transparent offset reporting and verification

### 3. Community Benefit Tracker (`community-benefits.clar`)
- Manages revenue sharing with local communities
- Tracks community development projects and funding
- Monitors local employment and economic impact
- Ensures transparent distribution of tourism benefits

### 4. Cultural Preservation System (`cultural-preservation.clar`)
- Manages cultural site protection and access controls
- Tracks cultural education programs and initiatives
- Monitors visitor impact on cultural heritage sites
- Supports traditional knowledge preservation efforts

### 5. Sustainability Certification (`sustainability-cert.clar`)
- Issues and manages sustainability certifications
- Tracks compliance with environmental and social standards
- Provides transparent certification scoring
- Enables third-party verification and auditing

## Key Features

- **Transparent Impact Tracking**: All environmental and social impacts are recorded on-chain
- **Community Empowerment**: Direct benefit sharing with local communities
- **Cultural Protection**: Safeguarding cultural heritage and traditional knowledge
- **Carbon Neutrality**: Comprehensive carbon offset management
- **Certification System**: Verifiable sustainability credentials
- **Conservation Funding**: Direct support for habitat protection programs

## Data Types

The system uses native Clarity data types including:
- `uint` for numerical values (emissions, offsets, scores)
- `principal` for user and organization identification
- `string-ascii` for names, descriptions, and metadata
- `bool` for status flags and verification states
- Maps and lists for complex data structures

## Usage

Each contract provides public functions for:
- Data recording and updates
- Status queries and reporting
- Verification and certification processes
- Benefit distribution and tracking

## Testing

Comprehensive test suite using Vitest covers:
- Contract deployment and initialization
- Data recording and retrieval
- Calculation accuracy
- Access control and permissions
- Integration between contracts

## Deployment

Deploy contracts in the following order:
1. `environmental-impact.clar`
2. `carbon-offset.clar`
3. `community-benefits.clar`
4. `cultural-preservation.clar`
5. `sustainability-cert.clar`
