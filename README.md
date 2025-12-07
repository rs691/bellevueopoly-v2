Project
Robert Stewart<robstewart@my365.bellevue.edu>
​You;​Robert Stewart;​Robert Stewart​
# Bellevueopoly - Phased Development Plan

## 🎯 Goal: Build a Working Demo in Logical Sections

-----

## Phase Breakdown (Ranked by Priority & Complexity)

### **PHASE 1: UI Foundation & Navigation** ⭐ START HERE

**Difficulty:** Easy | **Time:** 1-2 weeks | **Priority:** CRITICAL

**What you’ll build:**

- Splash screen with animated dice logo
- Login/Auth screen (mock for now)
- Zip code entry screen with range slider
- Basic navigation system (GoRouter)
- App theme system (purple gradient)
- Reusable UI components (buttons, cards, inputs)

**Why start here:**

- No backend dependencies
- Quick visual wins
- Establishes design system
- Easy to test and iterate
- Foundation for everything else

**Deliverable:** Beautiful, navigable app shell with no functionality yet

-----

### **PHASE 2: Map Integration & Store Display** ⭐⭐

**Difficulty:** Medium | **Time:** 1-2 weeks | **Priority:** CRITICAL

**What you’ll build:**

- Google Maps integration
- Mock store data (JSON file)
- Store markers on map
- Filter stores by zip code + range
- Highlight participating stores
- Center map on user’s zip code area

**Why second:**

- Core visual experience
- No real-time location needed yet
- Uses static data (easy to test)
- Shows progress quickly

**Deliverable:** Interactive map showing stores based on zip code

-----

### **PHASE 3: Store Detail Popup** ⭐⭐

**Difficulty:** Easy-Medium | **Time:** 1 week | **Priority:** HIGH

**What you’ll build:**

- Bottom sheet/modal popup
- Store “Property Card” design
- Display: name, image placeholder, description, promotions
- Check-in button (disabled for now)
- Close/dismiss functionality

**Why third:**

- Builds on Phase 2
- Still no complex logic
- Merchant-facing feature
- Easy to demo

**Deliverable:** Beautiful store details when tapping markers

-----

### **PHASE 4: Location Services & Proximity Detection** ⭐⭐⭐

**Difficulty:** Medium-Hard | **Time:** 1-2 weeks | **Priority:** HIGH

**What you’ll build:**

- Real-time GPS tracking
- Permission handling (location)
- Distance calculation to stores
- Proximity detection (within X meters)
- Enable/disable check-in based on distance
- Visual indicators (too far, nearby, in range)

**Why fourth:**

- Requires all previous phases
- Core game mechanic
- Complex permissions/testing
- Platform-specific code

**Deliverable:** Working proximity detection and check-in validation

-----

### **PHASE 5: Check-in System & Points** ⭐⭐⭐

**Difficulty:** Medium | **Time:** 1 week | **Priority:** MEDIUM

**What you’ll build:**

- Check-in functionality
- Points system (local storage)
- Visit tracking (prevent duplicates)
- Success animations/feedback
- Progress tracker (X/15 stores)
- Simple leaderboard (local only)

**Why fifth:**

- Needs location working first
- Requires data persistence
- Game mechanics start here

**Deliverable:** Functional check-in and point system

-----

### **PHASE 6: Offline Support & Queue Management** ⭐⭐⭐⭐

**Difficulty:** Hard | **Time:** 1-2 weeks | **Priority:** MEDIUM

**What you’ll build:**

- Offline detection
- Queue system for actions
- Local storage (Hive)
- Sync when online
- Network status indicators

**Why sixth:**

- Requires check-in system working
- Complex state management
- Critical for real-world use
- Can be MVP without it initially

**Deliverable:** App works offline and syncs later

-----

### **PHASE 7: Authentication & User Profiles** ⭐⭐⭐

**Difficulty:** Medium | **Time:** 1 week | **Priority:** MEDIUM

**What you’ll build:**

- Real Firebase/Supabase auth
- Email/password login
- Social login (Google, Apple)
- User profile storage
- Session management

**Why seventh:**

- Can use mock auth until now
- Backend dependency
- Needed for multi-user features

**Deliverable:** Real user accounts and profiles

-----

### **PHASE 8: Backend Integration** ⭐⭐⭐⭐

**Difficulty:** Hard | **Time:** 2-3 weeks | **Priority:** LOW (for demo)

**What you’ll build:**

- Firebase/Supabase setup
- Store data from database
- User data sync
- Real-time updates
- API endpoints

**Why eighth:**

- Can demo with local data until now
- Requires infrastructure
- Ongoing maintenance
- Multiple services to coordinate

**Deliverable:** Fully connected app with live data

-----

### **PHASE 9: Configuration System** ⭐⭐⭐

**Difficulty:** Medium | **Time:** 1 week | **Priority:** LOW (for demo)

**What you’ll build:**

- JSON config loader
- City configuration (Bellevue, Seattle, etc.)
- Theme system (Cyberpunk, Retro, Classic)
- Remote config (Firebase)
- White-label capability

**Why ninth:**

- Can hardcode initially
- Nice-to-have for demo
- Critical for platform scaling

**Deliverable:** Multi-city, multi-theme platform

-----

### **PHASE 10: Advanced Features** ⭐⭐⭐⭐⭐

**Difficulty:** Very Hard | **Time:** 3-4 weeks | **Priority:** FUTURE

**What you’ll build:**

- AR mode for finding stores
- Fog of war map
- Monopoly mechanics (rent, ownership)
- Chance cards
- Real leaderboards
- Push notifications
- Analytics dashboard

**Why last:**

- Polish and “wow” factor
- Not critical for MVP
- Requires everything else working
- High development cost

**Deliverable:** Full-featured game experience

-----

## 📋 Recommended Order for MVP Demo

### **SPRINT 1-2 (Weeks 1-2): Visual Foundation**

✅ Phase 1: UI Foundation & Navigation

### **SPRINT 3-4 (Weeks 3-4): Core Experience**

✅ Phase 2: Map Integration & Store Display  
✅ Phase 3: Store Detail Popup

### **SPRINT 5-6 (Weeks 5-6): Game Mechanics**

✅ Phase 4: Location Services & Proximity Detection  
✅ Phase 5: Check-in System & Points

### **SPRINT 7 (Week 7): Polish for Demo**

✅ Add mock data for 15 Bellevue stores  
✅ Test on multiple devices  
✅ Fix bugs and edge cases  
✅ Create demo script

### **POST-DEMO (Weeks 8+):**

✅ Phase 6: Offline Support  
✅ Phase 7: Real Authentication  
✅ Phase 8: Backend Integration  
✅ Phase 9: Configuration System  
✅ Phase 10: Advanced Features

-----

## 🎬 DEMO CHECKLIST (What You Need Working)

### Must Have:

- [ ] Beautiful UI with purple gradient theme
- [ ] Animated dice splash screen
- [ ] Zip code entry with range selector
- [ ] Map showing stores in range
- [ ] Store markers (purple pins)
- [ ] Tap marker → Store detail popup
- [ ] Store info: name, description, promo
- [ ] Real-time location tracking
- [ ] Distance to each store displayed
- [ ] Check-in button (enabled when close)
- [ ] Success feedback when checking in
- [ ] Progress tracker (X/15 visited)

### Nice to Have:

- [ ] Mock leaderboard
- [ ] Animations (dice roll, confetti)
- [ ] Sound effects
- [ ] Smooth transitions

### Can Skip for Demo:

- Real user accounts (use mock user)
- Backend/database (use JSON file)
- Offline mode (require internet)
- Multi-city support (Bellevue only)
- AR features
- Advanced game mechanics

-----

## 🧪 Testing Strategy by Phase

### Phase 1 Testing:

- UI looks good on different screen sizes
- Navigation flows correctly
- Theme applies consistently
- No visual glitches

### Phase 2 Testing:

- Map loads correctly
- Stores appear at right locations
- Zip code filtering works
- Map centers correctly

### Phase 3 Testing:

- Popup opens smoothly
- All data displays correctly
- Images load or show placeholder
- Close button works

### Phase 4 Testing:

- Location permissions granted
- GPS accuracy acceptable
- Distance calculations correct
- Proximity detection reliable
- Works on different devices

### Phase 5 Testing:

- Can only check in when nearby
- Points awarded correctly
- Can’t check in twice at same store
- Progress saves correctly

-----

## 📦 What You’ll Get at Each Phase

**After Phase 1:** Pretty app with navigation  
**After Phase 2:** Map with store markers  
**After Phase 3:** Interactive store details  
**After Phase 4:** Real location tracking  
**After Phase 5:** Working game demo ✨  
**After Phase 6:** Production-ready reliability  
**After Phase 7:** Multi-user support  
**After Phase 8:** Live platform  
**After Phase 9:** White-label SaaS  
**After Phase 10:** Full game experience

-----

## 🎯 Your Immediate Next Steps

1. **Start Phase 1** - I’ll create the UI foundation
1. **Review and test** the UI/navigation
1. **Approve design** before moving to Phase 2
1. **Iterate on feedback** as we go

This approach lets you:

- See progress quickly
- Test each piece thoroughly
- Change direction easily
- Demo at any phase
- Ship incrementally

Ready to start Phase 1? I’ll create:

- Splash screen with animated dice
- Login screen (mock)
- Zip code entry screen
- Main app shell with navigation
- Reusable UI components
- Purple gradient theme

-----

## 💡 Pro Tips

**For Fastest Demo:**

- Phases 1-5 are essential (5-7 weeks)
- Use mock data everywhere possible
- Skip authentication (use fake user)
- Hardcode Bellevue stores
- Test on 1-2 devices only
- Focus on happy path

**For Production:**

- Do all phases (15-20 weeks)
- Implement proper backend
- Handle all edge cases
- Comprehensive testing
- Multi-device support
- Security audit

**For Best Results:**

- Complete one phase fully before starting next
- Test thoroughly at each phase
- Get feedback from merchants early (Phase 3)
- Test with real users at Phase 5
- Budget 20% more time than estimated

signatureImage
Robert Stewart | Peer Tutoring
Bellevue University, 1000 Galvin Road South, Bellevue, Nebraska 68005-3098
Phone: 402.973.0084 | robstewart@my365.bellevue.edu