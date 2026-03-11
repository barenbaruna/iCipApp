# 🔍 Analisis Refactoring — iCipApp

> **Tanggal Analisis:** 11 Maret 2026  
> **Total File Dianalisis:** 28 Swift source files  
> **Arsitektur:** MVVM + SwiftData + Repository Pattern

---

## Ringkasan Eksekutif

Codebase iCipApp sudah memiliki struktur yang cukup baik dengan pemisahan layer (Core / Features / Shared). Namun terdapat beberapa area yang perlu direfactor untuk meningkatkan **type safety**, **testability**, **maintainability**, dan **performance**. Berikut adalah temuan yang diurutkan berdasarkan prioritas.

---

## 🔴 Prioritas Tinggi (Critical)

### 1. Raw String sebagai Tipe Data Domain

**File yang terdampak:**
- `Core/Models/Baby.swift` — `gender: String`
- `Core/Models/FoodLog.swift` — `reaction: String`
- `Features/Onboarding/OnboardingViewModel.swift` — `gender: String`, `genders: [String]`
- `Features/FoodDetail/FoodDetailViewModel.swift` — `logReaction: String = "Suka"`
- `Features/Profile/ProfileView.swift` — hardcoded string comparison `baby.gender == "Laki-laki"`

**Masalah:**
Penggunaan `String` mentah untuk nilai domain seperti gender dan reaksi makanan sangat rentan typo dan tidak ada compile-time safety. Sebagai contoh, di `ProfileView`, terdapat perbandingan string literal `baby.gender == "Laki-laki"` yang bisa salah kapan saja.

**Solusi yang Direkomendasikan:**
```swift
// Buat enum di Core/Models/
enum BabyGender: String, Codable, CaseIterable {
    case male = "Laki-laki"
    case female = "Perempuan"
    
    var systemImageName: String {
        switch self {
        case .male: return "figure.stand"
        case .female: return "figure.stand.dress"
        }
    }
}

enum FoodReaction: String, Codable, CaseIterable {
    case like = "Suka"
    case neutral = "Tidak Suka"
    case allergic = "Alergi"
    
    var emoji: String {
        switch self {
        case .like: return "😋"
        case .neutral: return "😐"
        case .allergic: return "🤧"
        }
    }
}
```

Kemudian ubah properti model:
```swift
// Baby.swift
var gender: BabyGender

// FoodLog.swift
var reaction: FoodReaction
```

---

### 2. Error Handling yang Tidak Memadai (Silent Failures)

**File yang terdampak:**
- `Features/Home/HomeViewModel.swift` — `print("Failed fetching data: \(error)")`
- `Features/FoodList/FoodListViewModel.swift` — `print("Failed to load recipes: \(error)")`
- `Features/FoodDetail/FoodDetailViewModel.swift` — `print("Failed to check logs:", ...)`, `print("Failed to save log:", ...)`
- `Features/Profile/ProfileViewModel.swift` — `print("Failed to load baby:", ...)`, `print("Reset error:", ...)`
- `Features/Onboarding/OnboardingViewModel.swift` — `print("Failed to save baby:", ...)`
- `Core/Repositories/LocalRecipeRepository.swift` — `print("ERROR parsing foods.json:", ...)`

**Masalah:**
Semua error hanya di-print ke console dan tidak pernah di-surface ke user. Ini membuat debugging di production tidak mungkin dan user tidak mendapat feedback saat operasi gagal.

**Solusi yang Direkomendasikan:**
```swift
// Tambahkan state error ke ViewModel
@Published var errorMessage: String?
@Published var hasError: Bool = false

func loadData() {
    do {
        ...
    } catch {
        self.errorMessage = "Gagal memuat data. Coba lagi."
        self.hasError = true
        // Juga log ke crash reporting service
    }
}
```

Tampilkan error di View menggunakan `.alert` atau `errorAlert` modifier.

---

### 3. ViewModel Hardcode Concrete Dependencies (Singleton)

**File yang terdampak:**
- `Features/Home/HomeViewModel.swift` — `private let recipeRepo = LocalRecipeRepository.shared`
- `Features/FoodList/FoodListViewModel.swift` — `private let recipeRepo = LocalRecipeRepository.shared`

**Masalah:**
ViewModel yang langsung menginstansiasi `LocalRecipeRepository.shared` tidak bisa di-unit test karena dependency tidak bisa di-mock/inject. Ini melanggar prinsip Dependency Inversion.

**Solusi yang Direkomendasikan:**
```swift
// HomeViewModel.swift
@MainActor
class HomeViewModel: ObservableObject {
    private let recipeRepo: RecipeRepositoryProtocol
    
    init(recipeRepo: RecipeRepositoryProtocol = LocalRecipeRepository.shared) {
        self.recipeRepo = recipeRepo
    }
}
```

Ini memungkinkan injection untuk testing:
```swift
// Dalam unit test
let mockRepo = MockRecipeRepository()
let viewModel = HomeViewModel(recipeRepo: mockRepo)
```

---

### 4. `setupConfigs` / `configure` Pattern yang Rawan Bug

**File yang terdampak:**
- `Features/Home/HomeViewModel.swift` — `func setupConfigs(modelContext: ModelContext)`
- `Features/FoodDetail/FoodDetailViewModel.swift` — `func configure(modelContext: ModelContext)`
- `Features/Profile/ProfileViewModel.swift` — `func configure(modelContext: ModelContext)`

**Masalah:**
Repository diinisialisasi di fungsi `setup`/`configure` yang dipanggil dari `onAppear`. Ini artinya ada window waktu di mana ViewModel belum siap digunakan, dan jika `onAppear` tidak dipanggil (misal dalam test), repository akan `nil` dan operasi akan diam-diam gagal.

**Solusi yang Direkomendasikan:**
Inject `ModelContext` langsung lewat initializer atau gunakan `@Environment` secara konsisten, atau gunakan SwiftData's `@Query` di View dan teruskan data ke ViewModel:

```swift
// Opsi 1: Init injection
init(modelContext: ModelContext) {
    self.babyRepo = SwiftDataBabyRepository(context: modelContext)
    loadBaby()
}

// Opsi 2: Gunakan @Query di View, teruskan data ke ViewModel
struct HomeView: View {
    @Query private var babies: [Baby]
    // ...lalu teruskan babies ke ViewModel
}
```

---

## 🟡 Prioritas Sedang (Important)

### 5. Import yang Tidak Digunakan

**File yang terdampak:**
- `Features/Home/HomeViewModel.swift` — `import Combine` (tidak ada publisher/subscriber)
- `Features/FoodList/FoodListViewModel.swift` — `import Combine` (tidak ada publisher/subscriber)
- `Features/FoodDetail/FoodDetailViewModel.swift` — `import Combine`
- `Features/Onboarding/OnboardingViewModel.swift` — `import Combine`
- `Features/Profile/ProfileViewModel.swift` — `import Combine`

**Masalah:**
`Combine` diimport di semua ViewModel padahal tidak ada penggunaan `Publisher`, `Subscriber`, `sink`, atau `cancellable` sama sekali. Ini menambah compile time dan membingungkan pembaca kode.

**Solusi:** Hapus semua `import Combine` dari ViewModel yang tidak menggunakan Combine.

---

### 6. Logika Filter Umur yang Duplikat

**File yang terdampak:**
- `Features/FoodList/FoodListViewModel.swift` — hardcoded filter strings `"6-8 bln"`, `"9-11 bln"`, `"12-24 bln"`
- `Shared/Components/PlaceholderFoodImage.swift` — logika `if ageMinimumMonths <= 8`, `<= 11`, else
- `Features/Home/HomeView.swift` — `textureChip(age: "6-8", ...)`, `"9-11"`, `"12-24"`

**Masalah:**
Boundary umur (6-8, 9-11, 12-24 bulan) tersebar di banyak tempat tanpa satu sumber kebenaran. Jika ada perubahan range umur, harus diubah di banyak tempat.

**Solusi yang Direkomendasikan:**
```swift
// Buat di Core/Models/AgeGroup.swift
enum AgeGroup: CaseIterable {
    case early    // 6-8 bulan
    case middle   // 9-11 bulan
    case advanced // 12-24 bulan
    
    var minMonths: Int {
        switch self {
        case .early: return 6
        case .middle: return 9
        case .advanced: return 12
        }
    }
    
    var maxMonths: Int {
        switch self {
        case .early: return 8
        case .middle: return 11
        case .advanced: return 24
        }
    }
    
    var displayName: String {
        switch self {
        case .early: return "6-8 bln"
        case .middle: return "9-11 bln"
        case .advanced: return "12-24 bln"
        }
    }
    
    var texture: String {
        switch self {
        case .early: return "Lumat"
        case .middle: return "Cincang"
        case .advanced: return "Keluarga"
        }
    }
}
```

---

### 7. `ProfileView` Masih Menggunakan `NavigationView` (Deprecated)

**File:** `Features/Profile/ProfileView.swift` — baris 22

**Masalah:**
```swift
NavigationView { // ❌ Deprecated di iOS 16+
```

Semua view lain (`HomeView`, `FoodListView`) sudah menggunakan `NavigationStack` (API modern). `ProfileView` masih menggunakan `NavigationView` lama yang deprecated.

**Solusi:**
```swift
NavigationStack { // ✅ iOS 16+
    ...
}
```

---

### 8. Magic Numbers dan Inline Font Sizes

**File yang terdampak:**
- `Features/Home/HomeView.swift` — `.font(.system(size: 20, weight: .bold, design: .rounded))` dan berbagai ukuran hardcoded
- `Features/FoodList/FoodListView.swift` — `.font(.system(size: 13, weight: .semibold))`
- `Features/FoodDetail/FoodDetailView.swift` — berbagai `.font(.system(size: 12, weight: .medium))`
- `Features/Profile/ProfileView.swift` — `.font(.system(size: 20, weight: .bold, design: .rounded))`

**Masalah:**
`AppFonts` sudah ada tapi tidak digunakan secara konsisten. Banyak tempat masih menggunakan `.font(.system(size:weight:))` secara inline, yang menyulitkan perubahan tipografi secara global.

**Solusi:** Pindahkan semua definisi font ke `AppFonts` dan gunakan secara konsisten.

---

### 9. `FoodListView` Memiliki Nested `ScrollView`

**File:** `Features/FoodList/FoodListView.swift` — baris 22–93

**Masalah:**
```swift
ScrollView { // ScrollView luar
    VStack {
        filterChips
        ScrollView { // ScrollView dalam — TIDAK PERLU
            LazyVGrid { ... }
        }
    }
}
```

`ScrollView` dalam tidak diperlukan karena parent-nya sudah `ScrollView`. Ini bisa menyebabkan konflik gesture scrolling.

**Solusi:** Hapus `ScrollView` dalam dan biarkan `LazyVGrid` langsung di dalam `VStack` di `ScrollView` luar.

---

### 10. `hideKeyboard()` Didefinisikan tapi Tidak Pernah Dipanggil

**File:** `Features/FoodList/FoodListView.swift` — baris 141–143

**Masalah:**
```swift
// Fungsi ini ada tapi tidak pernah digunakan di mana pun
private func hideKeyboard() {
    UIApplication.shared.sendAction(...)
}
```

Dead code yang membingungkan. Sudah ada `.searchable` modifier yang menangani dismissal keyboard secara otomatis.

**Solusi:** Hapus fungsi `hideKeyboard()` dari `FoodListView`.

---

### 11. `FoodLog.id` dan `Baby.id` Tidak Menggunakan `@Attribute(.unique)`

**File yang terdampak:**
- `Core/Models/Baby.swift` — `var id: UUID = UUID()`
- `Core/Models/FoodLog.swift` — `var id: UUID = UUID()`
- `Core/Models/GrowthMeasurement.swift` — `var id: UUID = UUID()`

**Masalah:**
UUID digunakan sebagai identifier unik, namun tidak ditandai dengan `@Attribute(.unique)` di SwiftData, sehingga tidak ada constraint unik di level database.

**Solusi:**
```swift
@Model
final class Baby {
    @Attribute(.unique) var id: UUID = UUID()
    // ...
}
```

---

### 12. `NSError` Generik untuk Error Custom

**File:** `Core/Repositories/SwiftDataRepositories.swift` — baris 60

**Masalah:**
```swift
throw NSError(domain: "Baby not found", code: 404, userInfo: nil)
```

Penggunaan `NSError` generik tidak idiomatis di Swift dan sulit di-handle secara spesifik.

**Solusi yang Direkomendasikan:**
```swift
// Buat di Core/Utilities/AppError.swift
enum RepositoryError: LocalizedError {
    case babyNotFound
    case saveFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .babyNotFound: return "Data bayi tidak ditemukan"
        case .saveFailed(let error): return "Gagal menyimpan: \(error.localizedDescription)"
        }
    }
}

// Penggunaan
throw RepositoryError.babyNotFound
```

---

## 🟢 Prioritas Rendah (Nice to Have)

### 13. Pertimbangkan `@Observable` Macro (iOS 17+)

**File yang terdampak:** Semua ViewModel

**Catatan:**
Jika target deployment iOS 17+, pertimbangkan migrasi dari `ObservableObject` + `@Published` ke macro `@Observable` baru yang lebih ringan dan otomatis. Namun ini adalah trade-off jika masih mendukung iOS 16.

```swift
// Sebelum (iOS 16+)
@MainActor
class HomeViewModel: ObservableObject {
    @Published var recommendedRecipes: [RecipeItem] = []
}

// Sesudah (iOS 17+)
@Observable
@MainActor
class HomeViewModel {
    var recommendedRecipes: [RecipeItem] = []
}
```

---

### 14. `ScaleButtonStyle` Ditempatkan di File yang Salah

**File:** `Features/Home/HomeView.swift` — baris 261–267

**Masalah:**
`ScaleButtonStyle` adalah komponen reusable yang ditempatkan di `HomeView.swift`. Ini melanggar prinsip single responsibility dan tidak bisa digunakan di tempat lain tanpa duplikasi.

**Solusi:** Pindahkan ke `Shared/Components/ScaleButtonStyle.swift`.

---

### 15. `AppColors.warmGradient` Tidak Pernah Digunakan

**File:** `Core/Utilities/Constants/AppColors.swift` — baris 52–56

**Masalah:**
```swift
static let warmGradient = LinearGradient(...) // Tidak pernah dipakai
```

Dead code di design system.

**Solusi:** Hapus atau berikan annotation `// TODO: Digunakan di versi selanjutnya` jika memang direncanakan.

---

### 16. Logika `ageInMonths` di `Baby` Model Tidak Memperhitungkan Waktu

**File:** `Core/Models/Baby.swift` — baris 31–35

**Masalah:**
```swift
var ageInMonths: Int {
    let calendar = Calendar.current
    let components = calendar.dateComponents([.month], from: dateOfBirth, to: Date())
    return components.month ?? 0 // Tidak memperhitungkan hari/minggu
}
```

Perhitungan ini hanya menghitung selisih bulan bulat, mengabaikan hari di dalam bulan. Bayi yang lahir tanggal 31 dan tanggal 1 bulan berikutnya akan dihitung sama.

**Solusi:**
```swift
var ageInMonths: Int {
    Calendar.current.dateComponents([.month], from: dateOfBirth, to: Date()).month ?? 0
}

// Tambahkan computed property yang lebih akurat
var ageDescription: String {
    let components = Calendar.current.dateComponents([.month, .day], from: dateOfBirth, to: Date())
    let months = components.month ?? 0
    let days = components.day ?? 0
    if months == 0 { return "\(days) hari" }
    return "\(months) bulan \(days) hari"
}
```

---

### 17. Konstanta Magic Number di `FoodListViewModel`

**File:** `Features/FoodList/FoodListViewModel.swift` — baris 21

**Masalah:**
```swift
let ageFilters = ["Semua", "6-8 bln", "9-11 bln", "12-24 bln"]
```

Filter umur di-hardcode sebagai array string. Duplikat dari masalah \#6 di atas.

**Solusi:** Gunakan `AgeGroup.allCases` seperti yang diusulkan di poin 6.

---

### 18. `FoodDetailView` Menerima `recipe` dan `conflicts` sebagai Dua Parameter Terpisah

**File:** `Features/FoodDetail/FoodDetailView.swift` dan `Features/Home/HomeView.swift`

**Masalah:**
```swift
// Di HomeView
NavigationLink(destination: FoodDetailView(recipe: recipe, conflicts: conflicts))

// Di FoodListView — conflicts selalu kosong!
NavigationLink(destination: FoodDetailView(recipe: recipe, conflicts: []))
```

`FoodListView` selalu melewatkan `conflicts: []` tanpa melakukan pengecekan alergi. Ini berarti peringatan alergi tidak pernah muncul di tab Eksplorasi.

**Solusi:** `FoodDetailView` seharusnya bisa mengambil data baby sendiri dan menghitung konflik secara internal, atau menerima baby langsung:

```swift
struct FoodDetailView: View {
    let recipe: RecipeItem
    // Ambil baby dari @Query atau @Environment
    @Query private var babies: [Baby]
    
    private var conflicts: [String] {
        guard let baby = babies.first else { return [] }
        return recipe.allergens.filter { baby.allergies.contains($0) }
    }
}
```

---

## 📊 Ringkasan Temuan

| Kategori | Jumlah Masalah | Prioritas |
|----------|---------------|-----------|
| Type Safety (enum) | 2 (gender, reaction) | 🔴 Tinggi |
| Error Handling | 6 file | 🔴 Tinggi |
| Dependency Injection | 3 ViewModel | 🔴 Tinggi |
| Setup Pattern (optional repo) | 3 ViewModel | 🔴 Tinggi |
| Import Tidak Digunakan | 5 file | 🟡 Sedang |
| Logika Duplikat (AgeGroup) | 3 file | 🟡 Sedang |
| NavigationView Deprecated | 1 file | 🟡 Sedang |
| Magic Numbers / Inline Font | 4 file | 🟡 Sedang |
| Nested ScrollView | 1 file | 🟡 Sedang |
| Dead Code | 3 item | 🟢 Rendah |
| @Observable Migration | Semua ViewModel | 🟢 Rendah |
| Alergi tidak dicek di FoodList | 1 bug fungsional | 🔴 Tinggi |

---

## 🗺️ Urutan Refactoring yang Disarankan

1. **Fase 1 — Model & Type Safety**
   - Buat `BabyGender` dan `FoodReaction` enum
   - Buat `AgeGroup` enum
   - Buat `RepositoryError` enum
   - Tambahkan `@Attribute(.unique)` ke model

2. **Fase 2 — Error Handling**
   - Tambahkan `@Published var errorMessage: String?` ke semua ViewModel
   - Tampilkan error ke user via `.alert`

3. **Fase 3 — Dependency Injection**
   - Inject `RecipeRepositoryProtocol` ke ViewModel via init
   - Perbaiki pattern `configure(modelContext:)` menjadi init injection

4. **Fase 4 — Bug Fix**
   - Perbaiki alergi yang tidak dicek di `FoodListView`
   - Ganti `NavigationView` dengan `NavigationStack` di `ProfileView`

5. **Fase 5 — Cleanup**
   - Hapus `import Combine` yang tidak digunakan
   - Hapus `hideKeyboard()` yang tidak dipakai
   - Hapus/perbaiki `warmGradient` yang tidak digunakan
   - Pindahkan `ScaleButtonStyle` ke Shared
   - Perbaiki nested `ScrollView`

---

*Dokumen ini dibuat berdasarkan analisis statis. Disarankan untuk menulis unit test setelah setiap refactoring untuk memverifikasi tidak ada regresi.*
