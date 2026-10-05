# Chat app

Chat App to implement message encryption that achieves End-to-End Encryption.

With this Project, I main to create a full E2EE with less third party libraries using websockets

## Backend

The backend architecture will be built with [Vapor](https://docs.vapor.codes/).

The repository is [Chat-backend](https://github.com/nshutinicolas/chat-app-backend)

## How to run the app

The minimum deployable version is iOS 17.6 and that means you need **Xcode 15+**

- Clone both this repo and the backend [repo](https://github.com/nshutinicolas/chat-app-backend)
- Open both projects in XCode and first run the server side
    - How to run a Vapor project
    ```swift
    swift run
    ```
    Make sure you have swift installed already
- In XCode, hit the run button with Mac are the runtime
- Run the App on any 2 different simulators to simulate the chat flow

### Project flow

| **Enter user name** | **Previous chat** |
| --- | --- |
| <img width="250" alt="Simulator Screenshot - iPhone 17 Pro - 2026-09-25 at 09 06 54" src="https://github.com/user-attachments/assets/0a279ea6-b482-4a54-97e5-017dbe7df5cf" /> | <img width="250" alt="Simulator Screenshot - iPhone 17 Pro - 2026-09-25 at 09 26 39" src="https://github.com/user-attachments/assets/12facf0b-9f4c-4359-8e17-c16d7ebaed66" /> |

| **Start new chat** | **Chat messages** |
| --- | --- |
| <img width="250" alt="Simulator Screenshot - iPhone 17 Pro - 2026-09-25 at 09 37 35" src="https://github.com/user-attachments/assets/9c09d168-9e0e-4629-827e-5bc6639aa1c9" /> | <img width="250" alt="Simulator Screenshot - iPhone 17 Pro - 2026-09-25 at 09 26 44" src="https://github.com/user-attachments/assets/e1561ce8-d766-44f1-9340-b82df57d3255" /> |

| **Adding media** |
| --- |
| <img width="250" alt="Simulator Screenshot - iPhone 17 Pro - 2026-09-25 at 09 26 52" src="https://github.com/user-attachments/assets/09609e9f-99ae-4b4f-80d1-dace65d067a5" /> |

### Presentation

<video src="https://github.com/user-attachments/assets/ca5ee320-9fb5-4d87-8612-341758b2f50e" />
