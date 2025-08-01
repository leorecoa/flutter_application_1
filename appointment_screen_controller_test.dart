import 'package:flutter_application_1/core/analytics/analytics_service.dart';
import 'package:flutter_application_1/core/errors/app_exceptions.dart';
import 'package:flutter_application_1/core/models/tenant_model.dart';
import 'package:flutter_application_1/core/providers/app_providers.dart';
import 'package:flutter_application_1/core/services/storage_service.dart';
import 'package:flutter_application_1/core/tenant/tenant_context.dart';
import 'package:flutter_application_1/core/tenant/tenant_repository.dart';
import 'package:flutter_application_1/features/appointments/domain/usecases/additional_appointment_usecases.dart';
import 'package:flutter_application_1/features/appointments/presentation/controllers/appointment_screen_controller.dart';
import 'package:flutter_application_1/features/appointments/presentation/providers/service_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// 1. Mocks for all external dependencies
class MockTenantRepository extends Mock implements TenantRepository {}

class MockTenantContext extends Mock implements TenantContext {}

class MockExportAppointmentsUseCase extends Mock
    implements ExportAppointmentsUseCase {}

class MockStorageService extends Mock implements StorageService {}

class MockAnalyticsService extends Mock implements AnalyticsService {}

class MockTenant extends Mock implements Tenant {}

// A helper class to listen to provider state changes.
class Listener<T> extends Mock {
  void call(T? previous, T next);
}

void main() {
  // 2. Declare late variables for mocks and the test container
  late MockTenantRepository mockTenantRepository;
  late MockTenantContext mockTenantContext;
  late MockExportAppointmentsUseCase mockExportAppointmentsUseCase;
  late MockStorageService mockStorageService;
  late MockAnalyticsService mockAnalyticsService;
  late MockTenant mockTenant;
  late ProviderContainer container;
  late AppointmentScreenController controller;

  // 3. Use setUp to initialize mocks and container before each test
  setUp(() {
    mockTenantRepository = MockTenantRepository();
    mockTenantContext = MockTenantContext();
    mockExportAppointmentsUseCase = MockExportAppointmentsUseCase();
    mockStorageService = MockStorageService();
    mockAnalyticsService = MockAnalyticsService();
    mockTenant = MockTenant();

    // ProviderContainer is a test-friendly way to read providers without a widget tree.
    container = ProviderContainer(
      overrides: [
        tenantRepositoryProvider.overrideWithValue(mockTenantRepository),
        tenantContextProvider.overrideWithValue(mockTenantContext),
        exportAppointmentsUseCaseProvider.overrideWithValue(
          mockExportAppointmentsUseCase,
        ),
        storageServiceProvider.overrideWithValue(mockStorageService),
        analyticsServiceProvider.overrideWithValue(mockAnalyticsService),
      ],
    );

    // Read the controller from the container
    controller = container.read(appointmentScreenControllerProvider.notifier);
  });

  tearDown(() {
    // Dispose the container to prevent state from leaking between tests
    container.dispose();
  });

  group('exportAppointments', () {
    const tenantId = 'test-tenant-id';
    const exportData = 'id,client_name\n1,Test Client';
    const filePath = '/downloads/agendamentos.csv';

    // Helper to set up mocks for the successful path
    void setupSuccessMocks() {
      when(() => mockTenant.id).thenReturn(tenantId);
      when(() => mockTenantContext.currentTenant).thenReturn(mockTenant);
      when(
        () => mockTenantRepository.checkTenantAccess(tenantId, 'export'),
      ).thenAnswer((_) async => true);
      when(
        () => mockExportAppointmentsUseCase.execute(),
      ).thenAnswer((_) async => exportData);
      when(
        () => mockStorageService.saveToDownloads(any(), exportData),
      ).thenAnswer((_) async => filePath);
      when(
        () => mockAnalyticsService.trackEvent(
          any(),
          parameters: any(named: 'parameters'),
        ),
      ).thenAnswer((_) async {});
    }

    test('should return file path and set state to data on success', () async {
      // Arrange
      setupSuccessMocks();
      final listener = Listener<AsyncValue<void>>();
      container.listen(
        appointmentScreenControllerProvider,
        listener.call,
        fireImmediately: true,
      );

      // Act
      final result = await controller.exportAppointments();

      // Assert
      expect(result, filePath);

      // Verify state transitions: initial -> loading -> data
      verifyInOrder([
        () => listener(null, const AsyncData(null)), // Initial state
        () => listener(const AsyncData(null), const AsyncLoading()),
        () => listener(const AsyncLoading(), const AsyncData(null)),
      ]);
      verifyNoMoreInteractions(listener);

      // Verify that all dependencies were called correctly
      verify(
        () => mockTenantRepository.checkTenantAccess(tenantId, 'export'),
      ).called(1);
      verify(() => mockExportAppointmentsUseCase.execute()).called(1);
      verify(
        () => mockStorageService.saveToDownloads(
          any(that: startsWith('agendamentos_')),
          exportData,
        ),
      ).called(1);
      verify(
        () => mockAnalyticsService.trackEvent(
          'appointments_exported',
          parameters: {
            'format': 'csv',
            'count': exportData.length,
            'filePath': filePath,
          },
        ),
      ).called(1);
    });

    test(
      'should return null and set state to error if tenant has no access',
      () async {
        // Arrange
        when(() => mockTenant.id).thenReturn(tenantId);
        when(() => mockTenantContext.currentTenant).thenReturn(mockTenant);
        // Mock the access check to return false
        when(
          () => mockTenantRepository.checkTenantAccess(tenantId, 'export'),
        ).thenAnswer((_) async => false);

        // Act
        final result = await controller.exportAppointments();

        // Assert
        expect(result, isNull);
        expect(controller.state, isA<AsyncError>());
        final capturedError = (controller.state as AsyncError).error;
        expect(capturedError, isA<UnauthorizedException>());
        expect(
          (capturedError as UnauthorizedException).message,
          'Seu plano não permite exportação de dados',
        );

        // Verify that the use case was NOT called
        verifyNever(() => mockExportAppointmentsUseCase.execute());
      },
    );

    test(
      'should return null and set state to error if use case throws exception',
      () async {
        // Arrange
        final exception = UseCaseException('Failed to generate export');
        when(() => mockTenant.id).thenReturn(tenantId);
        when(() => mockTenantContext.currentTenant).thenReturn(mockTenant);
        when(
          () => mockTenantRepository.checkTenantAccess(tenantId, 'export'),
        ).thenAnswer((_) async => true);
        // Mock the use case to throw an error
        when(
          () => mockExportAppointmentsUseCase.execute(),
        ).thenThrow(exception);

        // Act
        final result = await controller.exportAppointments();

        // Assert
        expect(result, isNull);
        expect(controller.state, isA<AsyncError>());
        expect((controller.state as AsyncError).error, exception);

        // Verify that storage and analytics were NOT called
        verifyNever(() => mockStorageService.saveToDownloads(any(), any()));
        verifyNever(
          () => mockAnalyticsService.trackEvent(
            any(),
            parameters: any(named: 'parameters'),
          ),
        );
      },
    );
  });
}
