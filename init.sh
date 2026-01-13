#!/bin/bash

# =============================================================================
# Myself 2.0 - Flutter Project Initialization Script
# =============================================================================
# This script initializes the development environment for Myself 2.0
# It is idempotent - safe to run multiple times
# =============================================================================

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Project directory
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}   Myself 2.0 - Project Initialization${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# =============================================================================
# HEALTH CHECKS
# =============================================================================

echo -e "${YELLOW}[1/6] Running health checks...${NC}"

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}ERROR: Flutter is not installed or not in PATH${NC}"
    echo "Please install Flutter: https://docs.flutter.dev/get-started/install"
    exit 1
fi
echo -e "${GREEN}  ✓ Flutter found${NC}"

# Check Flutter version
FLUTTER_VERSION=$(flutter --version | head -n 1)
echo -e "${GREEN}  ✓ $FLUTTER_VERSION${NC}"

# Check Dart SDK
if ! command -v dart &> /dev/null; then
    echo -e "${RED}ERROR: Dart SDK is not installed${NC}"
    exit 1
fi
echo -e "${GREEN}  ✓ Dart SDK found${NC}"

# Check for Xcode (macOS only)
if [[ "$OSTYPE" == "darwin"* ]]; then
    if command -v xcodebuild &> /dev/null; then
        echo -e "${GREEN}  ✓ Xcode found${NC}"
    else
        echo -e "${YELLOW}  ⚠ Xcode not found - iOS development unavailable${NC}"
    fi
fi

# Check for Android SDK
if [ -n "$ANDROID_HOME" ] || [ -n "$ANDROID_SDK_ROOT" ]; then
    echo -e "${GREEN}  ✓ Android SDK found${NC}"
else
    echo -e "${YELLOW}  ⚠ Android SDK not configured - Android development may be unavailable${NC}"
fi

echo ""

# =============================================================================
# FLUTTER PROJECT CREATION
# =============================================================================

echo -e "${YELLOW}[2/6] Checking Flutter project...${NC}"

if [ ! -f "pubspec.yaml" ]; then
    echo -e "${BLUE}  Creating new Flutter project...${NC}"

    # Create Flutter project in a temp directory and move contents
    flutter create --org com.infyneis --project-name myself_2_0 . --platforms ios,android

    echo -e "${GREEN}  ✓ Flutter project created${NC}"
else
    echo -e "${GREEN}  ✓ Flutter project already exists${NC}"
fi

echo ""

# =============================================================================
# DEPENDENCIES
# =============================================================================

echo -e "${YELLOW}[3/6] Installing dependencies...${NC}"

# Update pubspec.yaml with required dependencies if not already present
if ! grep -q "provider:" pubspec.yaml 2>/dev/null; then
    echo -e "${BLUE}  Adding project dependencies to pubspec.yaml...${NC}"

    # Create a backup
    cp pubspec.yaml pubspec.yaml.bak

    # Use flutter pub add for clean dependency management
    flutter pub add provider
    flutter pub add hive
    flutter pub add hive_flutter
    flutter pub add home_widget
    flutter pub add uuid
    flutter pub add intl
    flutter pub add google_fonts
    flutter pub add flutter_animate
    flutter pub add path_provider

    # Dev dependencies
    flutter pub add --dev hive_generator
    flutter pub add --dev build_runner
    flutter pub add --dev flutter_lints
    flutter pub add --dev mocktail

    echo -e "${GREEN}  ✓ Dependencies added${NC}"
else
    echo -e "${GREEN}  ✓ Dependencies already configured${NC}"
fi

# Install all dependencies
echo -e "${BLUE}  Running flutter pub get...${NC}"
flutter pub get
echo -e "${GREEN}  ✓ Dependencies installed${NC}"

echo ""

# =============================================================================
# PROJECT STRUCTURE
# =============================================================================

echo -e "${YELLOW}[4/6] Setting up project structure...${NC}"

# Create directory structure as per REQUIREMENTS.md
directories=(
    "lib/core/constants"
    "lib/core/theme"
    "lib/core/utils"
    "lib/features/affirmations/data/models"
    "lib/features/affirmations/data/repositories"
    "lib/features/affirmations/presentation/screens"
    "lib/features/affirmations/presentation/widgets"
    "lib/features/affirmations/presentation/providers"
    "lib/features/affirmations/domain/usecases"
    "lib/features/settings/data"
    "lib/features/settings/presentation/screens"
    "lib/features/settings/presentation/providers"
    "lib/features/onboarding/presentation/screens"
    "lib/features/onboarding/presentation/widgets"
    "lib/widgets/native_widget/android"
    "lib/widgets/native_widget/ios"
    "lib/l10n"
    "test/unit"
    "test/widget"
    "integration_test"
    "assets/images"
    "assets/fonts"
)

for dir in "${directories[@]}"; do
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        echo -e "${GREEN}  ✓ Created $dir${NC}"
    fi
done

echo -e "${GREEN}  ✓ Project structure ready${NC}"

echo ""

# =============================================================================
# CODE GENERATION
# =============================================================================

echo -e "${YELLOW}[5/6] Running code generation...${NC}"

# Check if build_runner is needed (look for .g.dart or .freezed.dart references)
if grep -rq "part '.*\.g\.dart'" lib/ 2>/dev/null || grep -rq "part '.*\.freezed\.dart'" lib/ 2>/dev/null; then
    echo -e "${BLUE}  Running build_runner...${NC}"
    flutter pub run build_runner build --delete-conflicting-outputs
    echo -e "${GREEN}  ✓ Code generation complete${NC}"
else
    echo -e "${GREEN}  ✓ No code generation required yet${NC}"
fi

echo ""

# =============================================================================
# VERIFICATION
# =============================================================================

echo -e "${YELLOW}[6/6] Running verification...${NC}"

# Run flutter analyze
echo -e "${BLUE}  Running flutter analyze...${NC}"
if flutter analyze --no-fatal-infos --no-fatal-warnings; then
    echo -e "${GREEN}  ✓ Static analysis passed${NC}"
else
    echo -e "${YELLOW}  ⚠ Static analysis has warnings (non-blocking)${NC}"
fi

# Run flutter test (if tests exist)
if [ -n "$(find test -name '*_test.dart' 2>/dev/null)" ]; then
    echo -e "${BLUE}  Running flutter test...${NC}"
    if flutter test; then
        echo -e "${GREEN}  ✓ All tests passed${NC}"
    else
        echo -e "${YELLOW}  ⚠ Some tests failed${NC}"
    fi
else
    echo -e "${GREEN}  ✓ No tests to run yet${NC}"
fi

# Verify Flutter doctor
echo -e "${BLUE}  Running flutter doctor (summary)...${NC}"
flutter doctor --verbose | head -20

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}   Initialization Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "Next steps:"
echo -e "  1. Open the project in your IDE"
echo -e "  2. Run ${BLUE}flutter run${NC} to start the app"
echo -e "  3. Check ${BLUE}features.json${NC} for implementation checklist"
echo ""
echo -e "Useful commands:"
echo -e "  ${BLUE}flutter run${NC}              - Run the app"
echo -e "  ${BLUE}flutter test${NC}             - Run tests"
echo -e "  ${BLUE}flutter analyze${NC}          - Static analysis"
echo -e "  ${BLUE}flutter pub run build_runner build${NC} - Code generation"
echo ""
