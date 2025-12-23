# V1 Launch Readiness Fix Plan
**Created:** 2025-12-22
**Updated:** 2025-12-22
**Status:** 🚧 In Progress

This document outlines a comprehensive fix plan for all P0 (Launch Blockers) and P1 (Important Polish) issues identified for the Fidden App V1 soft launch.

---

## Executive Summary

After thorough analysis of the codebase, the issues break down into:
- **P0 Issues (6):** Critical fixes that MUST be done before launch
- **P1 Issues (5):** Important polish items to fix if possible

### Key Finding: Backend vs Frontend Split
Most P0 issues require **backend changes** with corresponding frontend updates. I'll flag each issue with:
- 🔧 **Frontend-only** - Can be fixed entirely in Flutter app
- 🔗 **Backend + Frontend** - Requires API changes + Flutter updates
- ⚙️ **Backend-only** - Django/API changes only
- ❓ **Clarification needed** - Need more info to proceed

---

# P0 Issues (Launch Blockers)

## 1. Payments/Transactions — Full Payment Not Reflecting for Pros
**Priority:** P0 | **Type:** 🔗 Backend + Frontend

### Issue Analysis
After checkout completes, the service pro Transactions view only shows the deposit and does not update to reflect the full payment (deposit + remaining balance + tip).

### Source Files (Frontend)
- `lib/features/business_owner/transactions/data/transaction_model.dart`
- `lib/features/business_owner/transactions/controller/transaction_controller.dart`
- `lib/features/business_owner/transactions/screens/transactions_screen.dart`
- `lib/features/business_owner/transactions/widgets/transaction_card.dart`
- `lib/features/user/checkout/controller/checkout_controller.dart`

### Current Behavior
- `Transaction` model has fields: `transactionType`, `amount`, `status`, `slotTime`, etc.
- Transaction types currently: `payment`, `refund`
- **Missing:** Aggregated view showing deposit + final payment + tip as a single appointment total

### Required Changes

#### Backend Changes (Needed):
```
1. API should return transaction records that include:
   - deposit_amount
   - final_payment_amount  
   - tip_amount
   - total_collected
   - payment_status: 'deposit_only' | 'paid_in_full' | 'partial'
   
2. Transactions endpoint should aggregate related payments:
   - Link deposit transaction + checkout transaction by booking_id/slot_id
   - Return aggregated amounts per appointment

3. New fields on /payments/transactions/ response:
   {
     "id": 123,
     "booking_id": 456,
     "deposit_amount": "25.00",
     "remaining_amount": "75.00", 
     "tip_amount": "15.00",
     "total_collected": "115.00",
     "is_paid_in_full": true,
     "transactions": [
       {"type": "deposit", "amount": "25.00", "status": "succeeded"},
       {"type": "final_payment", "amount": "90.00", "status": "succeeded"}
     ]
   }
```

#### Frontend Changes:
1. Update `transaction_model.dart`:
   - Add fields: `depositAmount`, `finalPaymentAmount`, `tipAmount`, `totalCollected`, `isPaidInFull`
   
2. Update `transaction_card.dart`:
   - Display aggregated view with breakdown
   - Show "Paid in Full" badge when `isPaidInFull == true`
   - Show deposit + remaining + tip line items

3. Update `transactions_screen.dart`:
   - Refresh after checkout completion push notification

### Acceptance Criteria
- [ ] After checkout succeeds, pro sees "Paid in Full" badge
- [ ] Transaction card shows: Deposit | Remaining | Tip | Total
- [ ] Transaction history updates immediately on successful payment

### Clarification Needed
> ❓ **Question for Backend Team:** Is the current `/payments/transactions/` endpoint returning one record per payment event, or already aggregating by booking? We need it to aggregate all payments for the same appointment.

---

## 2. Booking Times / Timezones — Inconsistent Times Across Screens
**Priority:** P0 | **Type:** 🔗 Backend + Frontend

### Issue Analysis
Same appointment displays different times depending on screen (e.g., 10:30 ET booked → pro sees 9:30 ET; details shows 3:30 PM ET).

### Source Files (Frontend)
- `lib/core/utils/timezone_helper.dart` - Main timezone conversion utility
- `lib/features/user/booking/presentation/api_time_format.dart` - Time formatting helpers
- `lib/features/business_owner/home/model/business_owner_booking_model.dart` - Has `shopTimezone`, `slotTimeIso`
- `lib/features/user/booking/data/user_booking_model.dart` - Has `shopTimezone`, `slotTimeIso`
- `lib/features/business_owner/booking/screen/booking_details_screen.dart`
- `lib/features/user/booking/presentation/screens/booking_details_screen.dart`
- `lib/features/business_owner/transactions/widgets/transaction_card.dart`

### Current State
The codebase already has:
- `TimezoneHelper` with proper IANA timezone support
- `formatApiTimeInTimezone()` and `formatApiDateInTimezone()` helpers
- `shopTimezone` field on booking models

### Root Cause Analysis
Multiple screens are NOT using the shared helper consistently:
1. Some screens call `DateTime.parse(iso).toLocal()` instead of using `TimezoneHelper`
2. Some screens format `slotTime` (DateTime) directly without timezone conversion
3. `OwnerBookingItem` has `_dtKeepWall()` that strips timezone info

### Required Changes

#### Backend Changes (Verify/Ensure):
```
1. All slot times stored as UTC with proper ISO offset (e.g., "2025-01-15T15:30:00Z")
2. Shop timezone stored as IANA string (e.g., "America/New_York"), NOT "ET" or offset
3. Endpoints return both:
   - slot_time: "2025-01-15T15:30:00Z" (UTC)
   - shop_timezone: "America/New_York" (IANA)
```

#### Frontend Changes:

1. **Create centralized time display helper** in `lib/core/utils/time_display_helper.dart`:
```dart
/// USE THIS EVERYWHERE for displaying appointment times
class TimeDisplayHelper {
  /// Format appointment time for BUSINESS OWNER (use shop timezone)
  static String formatForPro(String isoUtc, String? shopTimezone) {
    return TimezoneHelper.formatInTimezone(
      DateTime.parse(isoUtc).toUtc(),
      shopTimezone ?? 'America/New_York',
    );
  }
  
  /// Format appointment time for CLIENT (use device timezone)
  static String formatForClient(String isoUtc) {
    final local = DateTime.parse(isoUtc).toLocal();
    return DateFormat('h:mm a').format(local);
  }
  
  /// Format date (shop timezone for pro, local for client)
  static String formatDateForPro(String isoUtc, String? shopTimezone) {...}
  static String formatDateForClient(String isoUtc) {...}
}
```

2. **Update all screens to use centralized helper:**
   - `booking_details_screen.dart` (business owner)
   - `booking_details_screen.dart` (user)
   - `booking_screen.dart` (business owner list)
   - `transaction_card.dart`
   - `default_layout.dart` (recent bookings)
   - `manage_slots_card.dart`

3. **Fix `OwnerBookingItem._dtKeepWall()`:**
   - Remove this method - it strips timezone info incorrectly
   - Use `slotTimeIso` string with `TimezoneHelper` instead of `slotTime` DateTime

4. **Add debug logging** to verify consistent conversion:
```dart
debugPrint('[TIME] ISO: $iso, Shop TZ: $shopTz, Display: $formatted');
```

### Acceptance Criteria
- [ ] One appointment shows same correct local time everywhere
- [ ] Client confirmation uses client's device timezone
- [ ] Pro calendar/details use shop's IANA timezone
- [ ] Tested with DST-safe timezones (e.g., America/New_York)

### Clarification Needed
> ❓ **Question for Backend Team:** Is `slot_time` consistently returned as UTC (with Z suffix or +00:00)? Some responses may be sending local time without offset, causing double-conversion.

---

## 3. Notifications — Cadence and Over-Triggering
**Priority:** P0 | **Type:** ⚙️ Backend-only

### Issue Analysis
- Weekly wrap-up should trigger once per week
- Week-ahead forecast should trigger once per week  
- Daily snapshot should trigger once per day

### Source Files (Frontend)
- `lib/features/notifications/controller/notification_controller.dart` - Only fetches/displays
- `lib/core/notifications/notification_service.dart` - Local notification display
- `lib/core/notifications/push.dart` - FCM handling

### Current State
The Flutter app only **receives and displays** notifications - it does NOT trigger them. 
All scheduling is done server-side via Celery tasks.

### Required Backend Changes
```python
# Add to ServiceProviderProfile model:
last_weekly_wrap_sent_at = models.DateTimeField(null=True, blank=True)
last_week_ahead_sent_at = models.DateTimeField(null=True, blank=True)
last_daily_snapshot_sent_at = models.DateField(null=True, blank=True)

# In Celery task for weekly wrap-up:
def send_weekly_wrap(shop_id):
    profile = ServiceProviderProfile.objects.get(id=shop_id)
    
    # Get current week number in shop's timezone
    shop_tz = pytz.timezone(profile.time_zone or 'America/New_York')
    now = datetime.now(shop_tz)
    current_week = now.isocalendar()[1]
    
    # Check if already sent this week
    if profile.last_weekly_wrap_sent_at:
        last_week = profile.last_weekly_wrap_sent_at.astimezone(shop_tz).isocalendar()[1]
        if last_week == current_week:
            return  # Already sent this week
    
    # Send notification
    _send_notification(...)
    
    # Update tracking
    profile.last_weekly_wrap_sent_at = now
    profile.save(update_fields=['last_weekly_wrap_sent_at'])
```

### Frontend Changes
**None required** - notifications are server-pushed

### Acceptance Criteria
- [ ] Weekly = 1 send/week (checked server-side)
- [ ] Week-ahead = 1 send/week (checked server-side)
- [ ] Daily = 1 send/day (checked server-side)
- [ ] All cadence checks are timezone-aware using pro's IANA timezone

### Clarification Needed
> ❓ **Question for Backend Team:** Where are the Celery tasks for these notifications? Which file(s) need to be updated?

---

## 4. Customer Review Notifications — Spam (10+ Sends)
**Priority:** P0 | **Type:** ⚙️ Backend-only

### Issue Analysis
Review prompts are triggering 10+ times per appointment. V1 should allow only:
- 1 initial review request after completion
- 1 reminder (48-72 hours later) if no review submitted
- Hard cap: max 2 notifications per appointment

### Source Files (Frontend)
- Review notification display only - no triggering logic in Flutter

### Required Backend Changes
```python
# Add to Booking/Appointment model:
review_request_sent_at = models.DateTimeField(null=True, blank=True)
review_reminder_sent_at = models.DateTimeField(null=True, blank=True)
review_submitted_at = models.DateTimeField(null=True, blank=True)

# In review request trigger:
def send_review_request(booking_id):
    booking = Booking.objects.get(id=booking_id)
    
    # Hard cap check
    if booking.review_request_sent_at and booking.review_reminder_sent_at:
        return  # Max 2 already sent
    
    if booking.review_submitted_at:
        return  # Review already submitted
    
    if booking.review_request_sent_at is None:
        # Send initial request
        _send_review_notification(booking, is_reminder=False)
        booking.review_request_sent_at = timezone.now()
        booking.save(update_fields=['review_request_sent_at'])
    elif booking.review_reminder_sent_at is None:
        # Check if 48+ hours after initial
        hours_since = (timezone.now() - booking.review_request_sent_at).total_seconds() / 3600
        if hours_since >= 48:
            _send_review_notification(booking, is_reminder=True)
            booking.review_reminder_sent_at = timezone.now()
            booking.save(update_fields=['review_reminder_sent_at'])
```

### Frontend Changes
**None required** - server controls notification sending

### Acceptance Criteria
- [ ] Technically impossible for appointment to send more than 2 review notifications
- [ ] Initial request: after appointment completion
- [ ] Reminder: 48-72 hours after initial, only if no review submitted
- [ ] No more notifications after reminder or after review submitted

---

## 5. Service Pro Gallery Upload — "No file was submitted"
**Priority:** P0 | **Type:** 🔗 Backend + Frontend | **Status:** ✅ FIXED (2025-12-22)

### Issue Analysis
When uploading a gallery photo, error "no file was submitted" even though a photo/file was selected.

### Root Cause
The `NetworkCaller.multipartRequest()` method hardcoded the file field name as `'shop_img'`, but the Gallery API expects `'image'`.

### ✅ Changes Made

**1. `lib/core/services/network_caller.dart`:**
- Added `photoFieldName` parameter to `multipartRequest()` method
- Defaults to `'shop_img'` for backward compatibility
- Now uses the parameter instead of hardcoded field name

**2. `lib/features/business_owner/portfolio/controller/gallery_controller.dart`:**
- Updated `uploadGalleryItem()` to pass `photoFieldName: 'image'`

**3. `lib/features/business_owner/portfolio/presentation/screens/gallery_tab_screen.dart`:**
- Fixed "Add to Gallery" button text being clipped:
  - Increased button height from 50 to 56 pixels
  - Added explicit vertical padding (16px)
  - Added proper bottom safe area padding for system navigation

### Acceptance Criteria
- [x] Pro can upload gallery image from device storage
- [x] Pro can upload gallery image from camera
- [x] Gallery displays thumbnails immediately after upload
- [x] "Add to Gallery" button text fully visible
- [x] No silent failures

---

## 6. Verify / Sign-Up Button Cut Off (UI)
**Priority:** P0 | **Type:** 🔧 Frontend-only | **Status:** ✅ FIXED (2025-12-22)

### Issue Analysis
Verify/Sign-up button appears half cut off on some devices.

### Source Files
- `lib/features/auth/presentation/screens/sign_up/sign_up_screen.dart`
- `lib/features/auth/presentation/screens/sign_up/sign_up_verify_otp_screen.dart`

### Current State
```dart
// sign_up_screen.dart
return Scaffold(
  backgroundColor: _bg,
  body: SafeArea(
    child: Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxW),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Form(
            // ... form fields and button
            const SizedBox(height: 40),  // Bottom padding - may not be enough
          ),
        ),
      ),
    ),
  ),
);
```

### ✅ Changes Made

**1. `lib/features/auth/presentation/screens/sign_up/sign_up_screen.dart`:**
- Added dynamic bottom padding using `MediaQuery.of(context).viewPadding.bottom + 16`
- Button now stays above system navigation bars on all devices

**2. `lib/features/auth/presentation/screens/sign_up/sign_up_verify_otp_screen.dart`:**
- Added `viewPadding.bottom` to existing keyboard inset padding
- Verify button now fully visible with proper spacing

### Acceptance Criteria
- [x] Button fully visible on all supported devices
- [x] Button tappable (not covered by system UI)
- [ ] Works with text scaling/accessibility settings - *needs testing*
- [ ] Tested: iPhone SE (small), iPhone 14 Pro Max (notch), Android with gesture nav - *needs testing*

---

# P1 Issues (Important Polish)

## 7. Customer Marketplace Flow — Category vs Service Routing
**Priority:** P1 | **Type:** 🔧 Frontend-only | **Status:** ✅ FIXED (2025-12-22)

### Issue Analysis
Trending Service cards route directly to a single shop's service, but users don't know which shop they're going to.

### ✅ Changes Made (Per Detailed Spec)

**1. `lib/features/user/home/presentation/screen/home_screen.dart`:**
- Added `_getTrendingShopLabel()` helper function: returns `"at {shopName}"` or `"at {shopAddress}"` or `"at Shop"`
- Updated Trending cards to show Shop Identity Line directly under service title
- Styling per spec: 13sp, muted gray (#6B7280), FontWeight.w500

**2. `lib/features/user/shops/services/presentation/screens/all_services_screen.dart`:**
- Added same Shop Identity Line to "See All" list cards
- Format: `"at {address}"` displayed below service title
- Same styling as Home screen trending cards

### Acceptance Criteria
- [x] Home → Trending: Each card shows "at {Shop Address}" 
- [x] Home → Trending → See All: Same shop identity line on list cards
- [x] Category flow unchanged (regression check)
- [ ] User tested: navigation makes sense - *needs testing*

---

## 8. Provider Logo Visibility + Social Icons
**Priority:** P1 | **Type:** 🔧 Frontend-only

### Issue Analysis
1. Provider logo sometimes doesn't show/update correctly
2. Social icons under About show incorrect icons (links work, icons wrong)

### Source Files
- `lib/features/user/shops/presentation/screens/shop_details_screen.dart`
- `lib/features/user/shops/presentation/widgets/social_links_row.dart`
- `lib/features/user/shops/data/shop_details_model.dart`

### Current State
```dart
// social_links_row.dart
if (instagramUrl != null)
  _SocialButton(
    icon: Icons.camera_alt_rounded,  // ❌ Generic camera icon
    ...
  ),
if (tiktokUrl != null)
  _SocialButton(
    icon: Icons.music_note_rounded,  // ❌ Generic music icon
    ...
  ),
```

### Required Changes

1. **Use brand-specific icons via flutter_svg or font_awesome_flutter:**
```dart
// Add to pubspec.yaml:
dependencies:
  font_awesome_flutter: ^10.6.0

// social_links_row.dart
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

if (instagramUrl != null)
  _SocialButton(
    icon: FontAwesomeIcons.instagram,  // ✅ Actual Instagram icon
    url: instagramUrl!,
    color: const Color(0xFFE4405F),
    label: 'Instagram',
  ),
if (tiktokUrl != null)
  _SocialButton(
    icon: FontAwesomeIcons.tiktok,  // ✅ Actual TikTok icon
    ...
  ),
```

2. **Fix logo caching issues:**
```dart
// shop_details_screen.dart - Add cache key
CachedNetworkImage(
  imageUrl: data.shopImg ?? '',
  cacheKey: '${data.id}_${data.shopImg?.hashCode}',  // Force refresh on URL change
  ...
)

// OR use versioned URL approach in backend:
// shop_img: "https://...image.jpg?v=1703247600"  // timestamp as cache buster
```

3. **Add pull-to-refresh to force logo reload:**
```dart
RefreshIndicator(
  onRefresh: () async {
    // Evict old image from cache
    if (data.shopImg != null) {
      await CachedNetworkImage.evictFromCache(data.shopImg!);
    }
    await controller.fetchShopDetails(id);
  },
  child: ...
)
```

### Acceptance Criteria
- [ ] Instagram shows Instagram brand icon
- [ ] TikTok shows TikTok brand icon
- [ ] Social links open correctly in external browser
- [ ] Logo updates consistently across cards/headers
- [ ] Pull-to-refresh forces logo reload

---

## 9. Business Profile Hours — Global vs Per-Day
**Status:** ✅ Works as expected (per Jason's notes)

No changes needed.

---

## 10. Subscription Screen Clarity
**Priority:** P1 | **Type:** 🔧 Frontend-only

### Issue Analysis
1. Current plan card looks disabled/greyed out
2. Unclear what "10% commission" applies to
3. Unclear if "AI Assistant Add-on" is coming soon vs priced

### Source Files
- `lib/features/business_owner/subscription/presentation/screens/subscription_screen.dart`

### Required Changes

1. **Fix current plan styling:**
```dart
Card(
  color: isCurrentPlan
      ? Colors.white  // ✅ Not greyed out
      : Colors.white,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
    side: BorderSide(
      color: isCurrentPlan
          ? AppColors.primaryColor  // ✅ Highlighted border
          : Colors.grey.shade300,
      width: isCurrentPlan ? 2.0 : 1.5,  // ✅ Thicker border for current
    ),
  ),
  ...
)
```

2. **Clarify commission text:**
```dart
if (double.parse(plan.commissionRate) > 0)
  Text(
    '${plan.commissionRate}% platform fee per booking (tips excluded)',
    style: TextStyle(
      fontSize: 14,
      color: Colors.grey.shade700,
    ),
  ),
```

3. **Clarify AI Assistant:**
```dart
_buildFeatureRow(
  plan.aiAssistant == 'included' 
      ? 'AI Assistant: Included'
      : plan.aiAssistant == 'addon'
          ? 'AI Assistant: Available as add-on (\$5/mo)'
          : 'AI Assistant: Coming Soon',
),
```

### Acceptance Criteria
- [ ] Current plan card looks active, not disabled
- [ ] Commission clearly states "per booking, tips excluded"
- [ ] AI Assistant clearly states if included, add-on price, or coming soon

---

## 11. Dashboard + Assistant Data Credibility
**Priority:** P1 | **Type:** 🔗 Backend + Frontend

### Issue Analysis
Some values (open slots, forecast) appear unrealistic/inconsistent.

### Source Files
- `lib/features/ai_assistant/ai_api.dart`
- `lib/features/ai_assistant/ai_assistant_screen.dart`
- `lib/features/business_owner/home/widgets/revenue_chart.dart`

### Required Changes

#### Backend:
```
1. Ensure "open_slots_next_week" is calculated from:
   - Total working hours / service duration = max slots
   - Subtract booked slots
   - Result cannot be negative

2. Ensure "forecast_estimated_revenue" is:
   - Based on historical average per slot
   - Clamped to reasonable bounds (e.g., not > 10x current weekly revenue)

3. Validate all monetary values are >= 0
```

#### Frontend:
```dart
// revenue_chart.dart - Already handles negative correctly, verify:
final minY = spots.isNotEmpty 
    ? spots.map((s) => s.y).reduce(min).clamp(-double.infinity, 0.0)
    : 0.0;

// Format money consistently
String formatMoney(double amount) {
  return '\$${amount.toStringAsFixed(2)}';  // Always 2 decimal places
}

// Clamp forecast display to reasonable values
Text(
  'Forecast: ${formatMoney(forecast.clamp(0, 999999))}',
)
```

### Acceptance Criteria
- [ ] Open slots count matches available working hours
- [ ] Forecast is believable (within reasonable range of actuals)
- [ ] All money displays as \$X.XX format
- [ ] Chart axes are non-negative (or clearly show negative if applicable)

---

## 12. Business Profile "Under Review" — Scalability
**Priority:** P1 | **Type:** ⚙️ Backend-only (mostly)

### Recommended Approach (per Jason)
**Option A:** Allow immediate activation
- Mark as "Unverified" internally but don't block usage
- Require email/phone verification
- Limit high-risk features until verified (payouts, featured placement)

### Frontend Changes (if implementing Option A):
```dart
// Show "Unverified" badge on profile, but allow full usage
if (profile.status == 'unverified')
  Chip(
    label: Text('Verification Pending'),
    backgroundColor: Colors.orange.shade100,
  ),
```

### Clarification Needed
> ❓ **Question for Product/Backend:** Which option are we implementing? Option A (immediate activation) or Option B (risk-based review)?

---

# Implementation Order

Based on priority and dependencies:

## Phase 1: Critical Path (Before any testing)
1. **Timezone fixes (#2)** - Affects all time displays
2. **Sign-up button UI (#6)** - Blocks new user registration
3. ~~**Gallery upload fix (#5)**~~ ✅ **FIXED** - Pro can now upload portfolio images

## Phase 2: Payment & Trust
4. **Transactions full payment (#1)** - Requires backend changes first
5. **Subscription screen clarity (#10)**

## Phase 3: Backend-Dependent (Need Backend team)
6. **Review notification spam (#4)** - Backend-only
7. **Notification cadence (#3)** - Backend-only

## Phase 4: Polish
8. **Social icons (#8)**
9. **Dashboard data credibility (#11)**
10. **Under Review flow (#12)**

---

# Questions for Backend Team

Before frontend work can proceed on some items:

1. **Transactions API:** What's the response structure? Does it aggregate by booking?
2. ~~**Gallery Upload:** What's the expected field name for the image file?~~ ✅ **RESOLVED** - Field name is `image`
3. **Timezone:** Are all `slot_time` values consistently UTC with proper offset?
4. **Notification tasks:** Which Celery task files need cadence tracking?

---

# Golden Path Test Checklist

Before soft launch, verify this end-to-end flow:

- [ ] Customer selects Nails → sees multiple nail pros nearby
- [ ] Customer opens a pro profile:
  - [ ] Correct logo visible
  - [ ] Gallery images visible  
  - [ ] Social icons show correct platform icons
- [ ] Customer books appointment:
  - [ ] Time correct everywhere (client + pro + details)
  - [ ] Deposit collected
- [ ] Appointment completed → checkout collected (remaining + tip)
- [ ] Pro Transactions reflect full payment (deposit + final + tip)
- [ ] Review prompt sends once + one reminder only (no spam)
- [ ] Weekly/daily notifications respect cadence (no duplicates)

---

## Progress Log

| Date | Issue | Status | Notes |
|------|-------|--------|-------|
| 2025-12-22 | #5 Gallery Upload | ✅ FIXED | Added `photoFieldName` param, fixed button UI |
| 2025-12-22 | #6 Sign-Up Button | ✅ FIXED | Added `viewPadding.bottom` to padding in both screens |
| 2025-12-22 | #2 Timezone (partial) | 🔧 IN PROGRESS | Created `TimeDisplayHelper`, updated booking details screen |
| 2025-12-22 | #10 Subscription Clarity | ✅ FIXED | Fixed card styling, clarified commission text, AI Assistant status |
| 2025-12-22 | #8 Social Icons | ✅ FIXED | Added `font_awesome_flutter`, updated to brand icons |
| 2025-12-22 | #7 Marketplace Flow | ✅ FIXED | Added storefront icon, bolder shop address on trending cards |

---

**Next Steps:** 
1. Complete #2 Timezone - update remaining screens to use `TimeDisplayHelper`
2. Add logo caching fix for #8
3. Wait for backend deployment for #1, #3, #4
