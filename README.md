# 📡 MultipeerConnectivityDemo  

This repository contains a **chat demo** using **MultipeerConnectivity** in iOS. The project showcases how to establish **peer-to-peer communication** between Apple devices without requiring an internet connection.  

- 📲 One device acts as the **host**, creating the chat room.  
- 👥 Other devices can **join the room** and exchange messages.  
- 🔄 The connection is established via **Bluetooth and Wi-Fi**, allowing seamless discovery of nearby peers.  

This project is a great reference for developers looking to implement **local device communication** using the **MultipeerConnectivity framework** in Swift.

---

## ⚠️ Important: Update the Service Name  

Before working on this project, it is **highly recommended** to update the service name to match your project name.  

### 🔧 Steps to Update the Service Name  

1️⃣ Open the file **MultipeerConnectivity.swift** inside the `Services` folder.

2️⃣ Locate the following code:  

   ```swift
   extension String {
       // Plist: Bonjour services
       static var serviceName = "mpc-demo"
   }
  ```
3️⃣ Change "mpc-demo" to your desired service name.

4️⃣ After updating the service name, go to your project’s Info.plist file.

5️⃣ Find the **Bonjour services** section in **Info.plist** and update the following items:  

   - **Item 0:** Replace `_mpc-demo._tcp` → `_yourServiceName._tcp`  
   - **Item 1:** Replace `_mpc-demo._udp` → `_yourServiceName._udp`
