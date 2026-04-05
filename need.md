# **House Helper Mobile Application with Real-Time Chat System**

## **Final Year Project Document**

---

## **1. Project Title**

**House Helper Mobile Application using Flutter, Django, and WebSocket-based Chat System**

---

## **2. Introduction**

With the increasing pace of modern life, individuals often face difficulty in finding reliable household service providers such as cleaners, electricians, plumbers, cooks, and babysitters. Traditional methods are inefficient and lack transparency.

This project proposes a **House Helper Mobile Application** that connects users with verified service providers through a digital platform. Additionally, the system integrates a **real-time chat feature using WebSocket technology**, enabling seamless communication between users and helpers.

---

## **3. Objectives**

### **Main Objective**

To develop a mobile-based platform that connects users with household service providers and enables real-time communication.

### **Specific Objectives**

* To provide an easy-to-use platform for booking services
* To enable helpers to register and manage their services
* To implement real-time communication between users and helpers
* To develop a secure and scalable backend system
* To provide rating and feedback functionality

---

## **4. Scope of the Project**

The system is designed for:

* Users seeking household services
* Service providers offering services

### **Functional Scope**

* User registration and authentication
* Service browsing and filtering
* Booking system
* Real-time chat system
* Ratings and reviews

---

## **5. Technology Stack**

### **Frontend**

* Flutter (Cross-platform mobile app)

### **Backend**

* Django (Web framework)
* Django REST Framework (API)
* Django Channels (WebSocket handling)

### **Database**

* SQLite (Development)


### **Other Tools**

* VS Code
* Postman
* GitHub
* Figma

---

## **6. System Architecture**

The application follows a **client-server architecture** with real-time communication support.

### **Components**

* **Flutter App:** Handles UI and user interaction
* **Django REST API:** Handles business logic and data processing
* **WebSocket Server (Django Channels):** Handles real-time messaging
* **Database:** Stores users, services, bookings, and messages

### **Architecture Flow**

1. Flutter app sends HTTP requests to Django API
2. Django processes requests and interacts with database
3. Chat communication is handled via WebSocket connections
4. Messages are stored in the database and broadcast in real-time

---

## **7. System Features**

### **User Module**

* Register and login
* Search for helpers
* Book services
* Chat with helpers in real-time
* Rate and review services

### **Helper Module**

* Register as service provider
* Manage services and pricing
* Accept/reject bookings
* Communicate with users via chat

### **Admin Module**

* Manage users and helpers
* Monitor bookings
* Control platform activities

---

## **8. Database Design**

### **Users Table**

* id
* name
* phone
* email
* password
* role (user/helper)

### **Services Table**

* id
* service_name

### **Helpers Table**

* id
* user_id
* service_id
* price
* location
* rating

### **Bookings Table**

* id
* user_id
* helper_id
* date
* status

### **Messages Table**

* id
* sender_id
* receiver_id
* message
* timestamp

---

## **9. Real-Time Chat System Design**

### **Technology Used**

* WebSocket Protocol
* Django Channels

### **Chat Workflow**

1. User opens chat with a helper
2. Flutter app establishes a WebSocket connection
3. Messages are sent through the WebSocket
4. Django Channels receives and broadcasts messages
5. Messages are stored in the database
6. Receiver gets messages instantly

---

### **Chat Room Logic**

Each chat session is uniquely identified using:

Room Name Format:

```
userID_helperID
```

Example:

```
12_45
```

---

### **WebSocket Communication Flow**

* Client connects to:

```
ws://server/ws/chat/room_name/
```

* Message format:

```
{
  "message": "Hello"
}
```

---

### **Key Chat Features**

* Real-time messaging
* Chat history storage
* Separate chat rooms
* Bidirectional communication

---

## **10. System Workflow**

1. User registers and logs in
2. User searches for a service
3. System displays available helpers
4. User books a helper
5. User initiates chat with helper
6. Helper responds in real-time
7. Service is completed
8. User provides rating and feedback

---

## **11. Advantages of the System**

* Fast and convenient service booking
* Real-time communication improves coordination
* Transparent system with ratings
* Scalable architecture
* Improved user experience

---

## **12. Limitations**

* Requires stable internet connection
* WebSocket setup adds complexity
* Limited adoption initially
* Dependency on backend server uptime

---

## **13. Future Enhancements**

* GPS-based helper tracking
* Online payment integration (eSewa, Khalti)
* Push notifications
* AI-based service recommendations
* Voice and video calling features
* Multi-language support

---

## **14. Conclusion**

The House Helper Mobile Application provides an efficient solution for connecting users with service providers. The integration of a **real-time chat system using WebSocket technology** enhances communication and user experience.

The use of Flutter and Django ensures a modern, scalable, and high-performance application suitable for real-world deployment.

---

## **15. References**

* Flutter Documentation
* Django Documentation
* Django REST Framework Documentation
* Django Channels Documentation
* Various online tutorials and research articles

---

## **16. Appendix (Optional for Implementation)**

### **Sample WebSocket Endpoint**

```
ws://127.0.0.1:8000/ws/chat/room_name/
```

### **Sample API Endpoint**

```
http://127.0.0.1:8000/helpers/
```

---


Final Year Project

---
