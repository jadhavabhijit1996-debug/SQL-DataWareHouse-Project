# SQL-DataWareHouse-Project

📘 Project Overview
This project is inspired by Data with Baraa and was created to strengthen my understanding of data warehousing concepts.
I worked through the complete process of building a warehouse solution, including:
Data Analysis → exploring and understanding the source data.
Data Architecture → designing how data flows across layers.
Data Modeling → creating schemas and structures for efficient storage and querying.
Data Flow Design → mapping the movement of data from source to warehouse.
Transformations → applying cleaning, standardization, and aggregation to prepare data for analytics.

🎯 Purpose
The goal of this project was hands-on learning: to practice how data is ingested, transformed, and stored in a warehouse, and to see how these concepts come together in a real-world style workflow.

🚀 Outcome
By completing this project, I gained practical experience in:
Designing end-to-end data pipelines.
Applying transformations effectively.
Understanding how architecture and modeling impact performance and usability.

🏗️ Data Architecture:

The project follows the Medallion Architecture with three layers:
Bronze Layer → Raw data ingested from CSV files into SQL Server.
Silver Layer → Cleaned, standardized, and normalized data prepared for analysis.
Gold Layer → Business‑ready data modeled into a star schema for reporting and analytics.

📂 Repository Structure:

Code
sql-datawarehouse-project/
│
├── datasets/            # Raw datasets (ERP and CRM data)
├── docs/                # Documentation and architecture diagrams
│   ├── Data_Flow.png
│   ├── Data_Integration.png
│   ├── Gold_Layer_Data_Model.png
│   ├── High_Level_DataWarehouse_Architecture.png
│   └── naming-conventions.md
│   └── data_catalog.md
├── scripts/             # SQL scripts for ETL and transformations
│   ├── bronze/
│   ├── silver/
│   └── gold/
│
├── tests/               # Test scripts and quality checks
└── README.md            # Project overview and instructions


🛠️ Tools & Technologies Used:

SQL Server Express → Database engine
SQL Server Management Studio (SSMS) → Query and management GUI
Draw.io → Architecture and data flow diagrams
GitHub → Version control and project hosting
