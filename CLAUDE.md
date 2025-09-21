# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Zoo Simulation Console Application built with .NET 9.0. The application simulates zoo management operations including animal acquisition, breeding, and trading. The project uses xUnit for testing and is structured as a C# console application with a main project (ZooSim) and a test project (ZooSim.Tests).

## Development Commands

### Build
```bash
dotnet build
```

### Run Tests
```bash
# Run all tests
dotnet test

# Run specific test by name filter
dotnet test --filter FullyQualifiedName~TestName
```

### Run Application
```bash
dotnet run --project ZooSim/ZooSim.csproj
```

## Architecture

The application follows a domain-driven design pattern with the following key components:

- **ZooSimulation**: Main simulation entry point that manages the game loop and user interactions
- **Zoo**: Central entity managing animals, finances, and interactions with animal sellers
- **ZooOwner**: Represents the player/owner of the zoo
- **AnimalSeller**: Merchant entities that provide animals for purchase
- **Animal/BuyableAnimal**: Domain models for animals in the zoo
- **ZooFinance**: Handles financial transactions and budget management

The simulation is console-based with Japanese language prompts and follows an interactive menu-driven approach where users make choices to manage their zoo.