# Memory Optimization (PERF-003)

## Target: Memory Footprint < 50MB

This document describes the memory optimization strategies implemented to ensure the Myself 2.0 app stays under 50MB memory footprint during normal operation.

## Implementation Strategy

### 1. Image Cache Optimization

**Problem**: Flutter's default image cache can grow unbounded, consuming significant memory.

**Solution**:
- Limit image cache to 50 images maximum
- Limit total cache size to 10MB
- Configured in `main.dart` at app startup via `MemoryOptimizer.configureImageCache()`

**Code Location**: `lib/core/utils/memory_optimizer.dart`

```dart
static const int maxImageCacheCount = 50;
static const int maxImageCacheSizeBytes = 10 * 1024 * 1024; // 10MB
```

### 2. Lazy Data Loading

**Problem**: Loading all data at startup increases initial memory footprint.

**Solution**:
- Hive boxes opened lazily on first access (not at initialization)
- Affirmations loaded after first frame is rendered
- Widget service initialized only when needed

**Code Location**:
- `lib/core/storage/hive_service.dart` - Lazy box opening
- `lib/main.dart` - Deferred affirmation loading

### 3. Memory-Efficient List Handling

**Problem**: Creating multiple list copies wastes memory.

**Solution**:
- Use `List.unmodifiable()` to return views instead of copies
- Lists are built lazily with `ListView.builder`
- Only visible items are kept in memory

**Code Location**:
- `lib/features/affirmations/presentation/providers/affirmation_provider.dart`
- `lib/core/utils/memory_optimizer.dart`

```dart
List<Affirmation> get affirmations =>
    MemoryOptimizer.unmodifiableCopy(_affirmations);
```

### 4. Proper Resource Disposal

**Problem**: Resources not properly disposed continue consuming memory.

**Solution**:
- All providers implement `dispose()` method
- Clear internal collections on dispose
- Trigger GC hints after cleanup

**Code Location**: `lib/features/affirmations/presentation/providers/affirmation_provider.dart`

```dart
@override
void dispose() {
  _affirmations.clear();
  _currentAffirmation = null;
  _lastDisplayedId = null;
  MemoryOptimizer.disposeAndCleanup();
  super.dispose();
}
```

### 5. Optimized List Rendering

**Problem**: Keeping all list items in memory, even off-screen ones.

**Solution**:
- Use `ListView.builder` for lazy item building
- Set `addAutomaticKeepAlives: false` to prevent caching off-screen items
- Limit `cacheExtent` to reduce pre-rendered items

**Code Location**:
- `lib/core/utils/memory_optimizer.dart` - `buildOptimizedList()`
- `lib/features/affirmations/presentation/screens/affirmation_list_screen.dart`

### 6. Memory Monitoring

**Problem**: Need to measure and verify memory usage.

**Solution**:
- Created `MemoryMonitor` utility to track memory usage
- Logs memory at key checkpoints during app lifecycle
- Provides warnings when approaching 50MB limit

**Code Location**: `lib/core/utils/memory_monitor.dart`

```dart
final monitor = MemoryMonitor();
await monitor.logMemoryUsage('After loading affirmations');
await monitor.logSummary(); // Shows if under 50MB target
```

## Testing

### Unit Tests
- Memory optimization utilities tested in `test/unit/memory_footprint_test.dart`
- Validates image cache limits
- Tests provider disposal
- Verifies unmodifiable list behavior
- Stress tests with 100-500 affirmations

### Manual Testing
1. Run app in profile mode: `flutter run --profile`
2. Use DevTools Memory profiler
3. Perform typical user workflows:
   - Create 50+ affirmations
   - Navigate between screens
   - Reorder affirmations
   - Delete affirmations
4. Verify memory stays under 50MB

### Expected Memory Usage by Component

| Component | Estimated Memory |
|-----------|-----------------|
| Flutter Framework | ~15-20 MB |
| Dart VM | ~5-10 MB |
| Hive Database | ~2-5 MB |
| Affirmations (100 items) | ~0.5 MB |
| UI Widgets | ~5-10 MB |
| Image Cache (limited) | ~5-10 MB |
| **Total** | **~35-45 MB** |

## Optimization Checklist

- [x] Configure image cache limits
- [x] Implement lazy box opening for Hive
- [x] Use unmodifiable list views
- [x] Implement proper dispose patterns
- [x] Use ListView.builder for lists
- [x] Create memory monitoring utilities
- [x] Add memory footprint tests
- [x] Document optimization strategies

## Monitoring in Production

### Debug Mode
Memory usage can be monitored via debug prints:
```
MemoryMonitor [After loading affirmations]: 38.42 MB ✅
```

### Release Mode
- Service protocol is disabled for security
- Memory monitoring happens silently
- Optimizations are still active

## Known Limitations

1. **Service Protocol**: Precise memory measurement requires debug mode
2. **Platform Differences**: iOS and Android may report different values
3. **Background Memory**: OS may reclaim memory when app is backgrounded

## Future Optimizations

If memory usage approaches 50MB:
1. Implement pagination for affirmation lists (> 1000 items)
2. Compress images more aggressively
3. Use lazy loading for settings
4. Implement custom text rendering optimizations

## References

- Flutter Performance Best Practices: https://docs.flutter.dev/perf/best-practices
- Dart Memory Management: https://dart.dev/guides/language/effective-dart/usage#avoid-memory-leaks
- Hive Performance: https://docs.hivedb.dev/#/README?id=performance
