#!/usr/bin/env python3
"""
Flutter Provider Migration Script
Automates migration from global variables to Provider state management
"""

import os
import re
import shutil
import json
from typing import Dict, List, Tuple, Set
from pathlib import Path
import argparse
from dataclasses import dataclass


@dataclass
class MigrationRule:
    """Defines a migration rule for global variable to provider replacement"""
    old_pattern: str
    new_replacement: str
    provider_type: str
    requires_consumer: bool = True
    requires_context_read: bool = False


class FlutterProviderMigrator:
    def __init__(self, input_dir: str, backup_dir: str = "backup"):
        self.input_dir = Path(input_dir)
        self.backup_dir = Path(backup_dir)
        self.migration_report = []
        self.files_modified = set()

        # Define migration rules
        self.migration_rules = self._setup_migration_rules()
        self.provider_imports = self._setup_provider_imports()

    def _setup_migration_rules(self) -> List[MigrationRule]:
        """Setup all migration rules for global variables to providers"""
        return [
            # Location State Migrations
            MigrationRule(r'\blatitudepick\b', 'locationState.latitudePick', 'LocationState'),
            MigrationRule(r'\blongitudepick\b', 'locationState.longitudePick', 'LocationState'),
            MigrationRule(r'\blatitudedrop\b', 'locationState.latitudeDrop', 'LocationState'),
            MigrationRule(r'\blongitudedrop\b', 'locationState.longitudeDrop', 'LocationState'),
            MigrationRule(r'\bpickupcontroller\b', 'locationState.pickupController', 'LocationState'),
            MigrationRule(r'\bdropcontroller\b', 'locationState.dropController', 'LocationState'),
            MigrationRule(r'\bpicktitle\b', 'locationState.pickTitle', 'LocationState'),
            MigrationRule(r'\bpicksubtitle\b', 'locationState.pickSubtitle', 'LocationState'),
            MigrationRule(r'\bdroptitle\b', 'locationState.dropTitle', 'LocationState'),
            MigrationRule(r'\bdropsubtitle\b', 'locationState.dropSubtitle', 'LocationState'),
            MigrationRule(r'\bdroptitlelist\b', 'locationState.dropTitleList', 'LocationState'),
            MigrationRule(r'\bdestinationlat\b', 'locationState.destinationLat', 'LocationState'),
            MigrationRule(r'\bonlypass\b', 'locationState.onlyPass', 'LocationState'),
            MigrationRule(r'\bdestinationlong\b', 'locationState.destinationLong', 'LocationState'),
            MigrationRule(r'\bpicanddrop\b', 'locationState.picAndDrop', 'LocationState'),
            MigrationRule(r'\baddresspickup\b', 'locationState.addressPickup', 'LocationState'),
            MigrationRule(r'\blathomecurrent\b', 'locationState.latHomeCurrent', 'LocationState'),
            MigrationRule(r'\blonghomecurrent\b', 'locationState.longHomeCurrent', 'LocationState'),

            # Map State Migrations
            MigrationRule(r'\bmapController\b', 'mapState.mapController', 'MapState'),
            MigrationRule(r'\bmarkers\b(?!\s*\[)', 'mapState.markers', 'MapState'),
            MigrationRule(r'\bmarkers11\b', 'mapState.markers11', 'MapState'),
            MigrationRule(r'\bpolylines\b(?!\s*\[)', 'mapState.polylines', 'MapState'),
            MigrationRule(r'\bpolylines11\b', 'mapState.polylines11', 'MapState'),
            MigrationRule(r'\bpolylineCoordinates\b', 'mapState.polylineCoordinates', 'MapState'),
            MigrationRule(r'\bpolylinePoints\b(?!\s*=)', 'mapState.polylinePoints', 'MapState'),
            MigrationRule(r'\bpolylinePoints11\b', 'mapState.polylinePoints11', 'MapState'),

            # Pricing State Migrations
            MigrationRule(r'\bdropprice\b', 'pricingState.dropprice', 'PricingState'),
            MigrationRule(r'\bminimumfare\b', 'pricingState.minimumfare', 'PricingState'),
            MigrationRule(r'\bmaximumfare\b', 'pricingState.maximumfare', 'PricingState'),
            MigrationRule(r'\bamountresponse\b', 'pricingState.amountresponse', 'PricingState'),
            MigrationRule(r'\bresponsemessage\b', 'pricingState.responsemessage', 'PricingState'),
            MigrationRule(r'\bpriceyourfare\b', 'pricingState.priceyourfare', 'PricingState'),
            MigrationRule(r'\bglobalcurrency\b', 'pricingState.globalcurrency', 'PricingState'),
            MigrationRule(r'\bwalleteamount\b', 'pricingState.walleteamount', 'PricingState'),

            # Ride Request State Migrations
            MigrationRule(r'\bbuttontimer\b', 'rideRequestState.buttonTimer', 'RideRequestState'),
            MigrationRule(r'\bmid\b(?=\s*[=;])', 'rideRequestState.mid', 'RideRequestState'),
            MigrationRule(r'\bmroal\b', 'rideRequestState.mroal', 'RideRequestState'),
            MigrationRule(r'\bselect1\b', 'rideRequestState.select1', 'RideRequestState'),

            # Socket Service Migrations
            MigrationRule(r'\bsocket\s*!\s*\.connect\(\)', 'SocketService.instance.connect()', 'SocketService', False),
            MigrationRule(r'\bsocket\s*!\s*\.disconnect\(\)', 'SocketService.instance.disconnect()', 'SocketService', False),
            MigrationRule(r'\bsocket\s*!\s*\.emit\(', 'SocketService.instance.emit(', 'SocketService', False),
            MigrationRule(r'\bsocket\s*!\s*\.on\(', 'SocketService.instance.on(', 'SocketService', False),
            MigrationRule(r'\bsocket\s*\?\s*\.connected', 'SocketService.instance.isConnected', 'SocketService', False),
        ]

    def _setup_provider_imports(self) -> Dict[str, str]:
        """Setup required imports for providers"""
        return {
            'LocationState': "import '../providers/location_state.dart';",
            'MapState': "import '../providers/map_state.dart';",
            'PricingState': "import '../providers/pricing_state.dart';",
            'RideRequestState': "import '../providers/ride_request_state.dart';",
            'SocketService': "import '../services/socket_service.dart';",
            'TimerState': "import '../providers/timer_state.dart';",
            'Provider': "import 'package:provider/provider.dart';",
        }

    def backup_files(self):
        """Create backup of all files before migration"""
        if self.backup_dir.exists():
            shutil.rmtree(self.backup_dir)

        print(f"📁 Creating backup in {self.backup_dir}")
        shutil.copytree(self.input_dir, self.backup_dir)
        print("✅ Backup created successfully")

    def find_dart_files(self) -> List[Path]:
        """Find all Dart files in the input directory"""
        dart_files = []
        for file_path in self.input_dir.rglob("*.dart"):
            # Skip backup directory and test files
            if "test" not in str(file_path) and "backup" not in str(file_path):
                dart_files.append(file_path)

        print(f"📄 Found {len(dart_files)} Dart files to process")
        return dart_files

    def analyze_file_dependencies(self, content: str) -> Set[str]:
        """Analyze which providers a file needs based on its content"""
        needed_providers = set()

        for rule in self.migration_rules:
            if re.search(rule.old_pattern, content):
                needed_providers.add(rule.provider_type)

        return needed_providers

    def add_provider_imports(self, content: str, needed_providers: Set[str]) -> str:
        """Add necessary provider imports to file"""
        lines = content.split('\n')
        import_section_end = 0

        # Find end of import section
        for i, line in enumerate(lines):
            if line.strip().startswith('import '):
                import_section_end = i

        # Add missing imports
        for provider in needed_providers:
            import_statement = self.provider_imports.get(provider, '')
            if import_statement and import_statement not in content:
                lines.insert(import_section_end + 1, import_statement)
                import_section_end += 1

        # Always add Provider import if not present
        provider_import = self.provider_imports['Provider']
        if provider_import not in content and needed_providers:
            lines.insert(import_section_end + 1, provider_import)

        return '\n'.join(lines)

    def add_consumer_wrapper(self, content: str, needed_providers: Set[str]) -> str:
        """Add Consumer wrapper around build method if needed"""
        if not needed_providers or 'Provider' in content:
            return content

        # Find build method pattern
        build_pattern = r'(Widget\s+build\s*\(\s*BuildContext\s+context\s*\)\s*\{)'
        match = re.search(build_pattern, content)

        if not match:
            return content

        # Generate Consumer wrapper based on needed providers
        providers = list(needed_providers)[:4]  # Limit to Consumer4
        consumer_num = len(providers)

        if consumer_num == 1:
            consumer_type = f"Consumer<{providers[0]}>"
            consumer_params = f"context, {providers[0].lower()}, child"
        elif consumer_num == 2:
            consumer_type = f"Consumer2<{', '.join(providers)}>"
            consumer_params = f"context, {providers[0].lower()}, {providers[1].lower()}, child"
        elif consumer_num == 3:
            consumer_type = f"Consumer3<{', '.join(providers)}>"
            consumer_params = f"context, {providers[0].lower()}, {providers[1].lower()}, {providers[2].lower()}, child"
        elif consumer_num >= 4:
            consumer_type = f"Consumer4<{', '.join(providers[:4])}>"
            consumer_params = f"context, {providers[0].lower()}, {providers[1].lower()}, {providers[2].lower()}, {providers[3].lower()}, child"

        # Add consumer wrapper
        replacement = f'''\\1
    final locationState = Provider.of<LocationState>(context);
    final mapState = Provider.of<MapState>(context);
    final pricingState = Provider.of<PricingState>(context);
    final rideRequestState = Provider.of<RideRequestState>(context);

    return {consumer_type}(
      builder: ({consumer_params}) {{'''

        # Find the return statement in build method
        return_pattern = r'(\s*return\s+)'
        content = re.sub(build_pattern, replacement, content)

        # Close the consumer at the end of build method
        content = self._close_consumer_wrapper(content)

        return content

    def _close_consumer_wrapper(self, content: str) -> str:
        """Close the Consumer wrapper at the end of build method"""
        lines = content.split('\n')
        build_method_found = False
        brace_count = 0
        build_end_line = -1

        for i, line in enumerate(lines):
            if 'Widget build(BuildContext context)' in line:
                build_method_found = True
                continue

            if build_method_found:
                brace_count += line.count('{') - line.count('}')
                if brace_count == 0:
                    build_end_line = i
                    break

        if build_end_line > 0:
            # Add closing brace and semicolon before the last brace
            lines.insert(build_end_line, '      });')

        return '\n'.join(lines)

    def apply_migration_rules(self, content: str) -> Tuple[str, List[str]]:
        """Apply all migration rules to content"""
        applied_rules = []

        for rule in self.migration_rules:
            old_content = content

            # Skip if inside a string literal
            content = self._safe_replace(content, rule.old_pattern, rule.new_replacement)

            if content != old_content:
                applied_rules.append(f"{rule.old_pattern} → {rule.new_replacement}")

        return content, applied_rules

    def _safe_replace(self, content: str, pattern: str, replacement: str) -> str:
        """Safely replace pattern avoiding string literals and comments"""
        lines = content.split('\n')
        modified_lines = []

        for line in lines:
            # Skip lines that are comments
            if line.strip().startswith('//') or line.strip().startswith('*'):
                modified_lines.append(line)
                continue

            # Check if pattern is inside string literals
            in_string = False
            quote_char = None
            i = 0
            modified_line = line

            # Simple string detection (can be improved)
            if "'" in line or '"' in line:
                # Only replace if not inside strings
                if not self._is_in_string(line, pattern):
                    modified_line = re.sub(pattern, replacement, line)
            else:
                modified_line = re.sub(pattern, replacement, line)

            modified_lines.append(modified_line)

        return '\n'.join(modified_lines)

    def _is_in_string(self, line: str, pattern: str) -> bool:
        """Check if pattern is inside a string literal"""
        # Simple heuristic: if pattern is between quotes
        import re
        string_patterns = [r'"[^"]*"', r"'[^']*'"]

        for string_pattern in string_patterns:
            for match in re.finditer(string_pattern, line):
                if pattern in match.group():
                    return True
        return False

    def add_context_read_calls(self, content: str) -> str:
        """Add context.read<Provider>() calls for state updates"""
        # Pattern for direct state assignments that should use context.read
        patterns = [
            (r'locationState\.(\w+)\s*=', r'context.read<LocationState>().set\1('),
            (r'mapState\.(\w+)\s*=', r'context.read<MapState>().set\1('),
            (r'pricingState\.(\w+)\s*=', r'context.read<PricingState>().set\1('),
            (r'rideRequestState\.(\w+)\s*=', r'context.read<RideRequestState>().set\1('),
        ]

        for pattern, replacement in patterns:
            content = re.sub(pattern, replacement, content)

        return content

    def update_clear_global_state_method(self, content: str) -> str:
        """Update _clearGlobalState method to use providers"""
        clear_method_pattern = r'void\s+_clearGlobalState\s*\(\s*\)\s*\{[^}]+\}'

        new_clear_method = '''void _clearGlobalState() {
    if (mounted) {
      context.read<LocationState>().clearLocationData();
      context.read<PricingState>().clearPricingData();
      context.read<RideRequestState>().clearRideRequest();
      context.read<MapState>().clearMapData();
    }
  }'''

        return re.sub(clear_method_pattern, new_clear_method, content, flags=re.DOTALL)

    def update_navigation_calls(self, content: str) -> str:
        """Update navigation calls to use provider data"""
        # Pattern for HomeScreen navigation
        home_screen_pattern = r'HomeScreen\s*\(\s*([^)]+)\s*\)'

        def replace_home_screen(match):
            # Replace with provider-based parameters
            return '''HomeScreen(
        latpic: locationState.latitudePick,
        longpic: locationState.longitudePick,
        latdrop: locationState.latitudeDrop,
        longdrop: locationState.longitudeDrop,
        destinationlat: locationState.destinationLat
      )'''

        return re.sub(home_screen_pattern, replace_home_screen, content, flags=re.DOTALL)

    def process_file(self, file_path: Path) -> Dict:
        """Process a single Dart file"""
        try:
            # Read file content
            with open(file_path, 'r', encoding='utf-8') as f:
                original_content = f.read()

            content = original_content

            # Analyze dependencies
            needed_providers = self.analyze_file_dependencies(content)

            if not needed_providers:
                return {
                    'file': str(file_path),
                    'status': 'skipped',
                    'reason': 'No global variables found',
                    'changes': []
                }

            # Add provider imports
            content = self.add_provider_imports(content, needed_providers)

            # Apply migration rules
            content, applied_rules = self.apply_migration_rules(content)

            # Add Consumer wrapper if needed
            if 'StatefulWidget' in content or 'StatelessWidget' in content:
                content = self.add_consumer_wrapper(content, needed_providers)

            # Add context.read calls
            content = self.add_context_read_calls(content)

            # Update specific methods
            content = self.update_clear_global_state_method(content)
            content = self.update_navigation_calls(content)

            # Write modified content
            if content != original_content:
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(content)

                self.files_modified.add(str(file_path))

                return {
                    'file': str(file_path),
                    'status': 'modified',
                    'providers_needed': list(needed_providers),
                    'changes': applied_rules,
                    'lines_changed': len(content.split('\n')) - len(original_content.split('\n'))
                }
            else:
                return {
                    'file': str(file_path),
                    'status': 'no_changes',
                    'providers_needed': list(needed_providers),
                    'changes': []
                }

        except Exception as e:
            return {
                'file': str(file_path),
                'status': 'error',
                'error': str(e),
                'changes': []
            }

    def generate_report(self, results: List[Dict], output_file: str = "migration_report.json"):
        """Generate migration report"""
        summary = {
            'total_files': len(results),
            'modified_files': len([r for r in results if r['status'] == 'modified']),
            'skipped_files': len([r for r in results if r['status'] == 'skipped']),
            'error_files': len([r for r in results if r['status'] == 'error']),
            'total_changes': sum(len(r.get('changes', [])) for r in results),
        }

        report = {
            'summary': summary,
            'details': results,
            'migration_rules_applied': len(self.migration_rules),
            'files_modified': list(self.files_modified)
        }

        # Write JSON report
        with open(output_file, 'w') as f:
            json.dump(report, f, indent=2)

        # Print summary
        print("\n" + "="*50)
        print("🎯 MIGRATION COMPLETE")
        print("="*50)
        print(f"📊 Total files processed: {summary['total_files']}")
        print(f"✅ Files modified: {summary['modified_files']}")
        print(f"⏭️  Files skipped: {summary['skipped_files']}")
        print(f"❌ Files with errors: {summary['error_files']}")
        print(f"🔄 Total changes applied: {summary['total_changes']}")
        print(f"📋 Report saved to: {output_file}")

        if summary['error_files'] > 0:
            print("\n❌ Files with errors:")
            for result in results:
                if result['status'] == 'error':
                    print(f"  - {result['file']}: {result['error']}")

    def migrate(self, report_file: str = "migration_report.json"):
        """Run the complete migration process"""
        print("🚀 Starting Flutter Provider Migration")
        print("="*50)

        # Create backup
        self.backup_files()

        # Find all Dart files
        dart_files = self.find_dart_files()

        # Process each file
        results = []
        for i, file_path in enumerate(dart_files, 1):
            print(f"📝 Processing ({i}/{len(dart_files)}): {file_path.name}")
            result = self.process_file(file_path)
            results.append(result)

            if result['status'] == 'modified':
                print(f"  ✅ Modified with {len(result['changes'])} changes")
            elif result['status'] == 'error':
                print(f"  ❌ Error: {result['error']}")
            else:
                print(f"  ⏭️  Skipped")

        # Generate report
        self.generate_report(results, report_file)

        return results


def main():
    parser = argparse.ArgumentParser(description='Flutter Provider Migration Tool')
    parser.add_argument('--input', '-i', default='lib',
                        help='Input directory (default: lib)')
    parser.add_argument('--backup', '-b', default='backup',
                        help='Backup directory (default: backup)')
    parser.add_argument('--report', '-r', default='migration_report.json',
                        help='Report file (default: migration_report.json)')
    parser.add_argument('--dry-run', action='store_true',
                        help='Show what would be changed without modifying files')

    args = parser.parse_args()

    migrator = FlutterProviderMigrator(args.input, args.backup)

    if args.dry_run:
        print("🔍 DRY RUN MODE - No files will be modified")
        # In dry run, we'd analyze but not write changes

    migrator.migrate(args.report)


if __name__ == "__main__":
    main()