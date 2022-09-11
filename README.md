# AuraluxWeb
## Routes
| URL                             | HTTP Method | Description                                              | Content (Body)          | Result (Body)          |
|---------------------------------|:-----------:|----------------------------------------------------------|-------------------------|------------------------|
| /users/login                    |     POST    | Check username and password and return token  | Basic auth in headers and `LoginRequest`   | `NewSession`           |
| /users/me                       |     GET     | Get user info                                            | none                    | `User.public`           |
| /submission              |      GET    |  Return list of ur submissions        |  none                |  `[Submission.Public]`    |
| /submission/submit              |     POST    | Get file to compile it and add to submission list        | `Submit`                | `Submission.Public`    |
| /submission/comments            |     GET     | Return compiler comments                                 | `SubmitInformationRequest`| `String`             |
| /submission/source              |     GET     | Return source of submission                              | `SubmitInformationRequest`| `String`             |
| /submission/author              |     GET     | Return username of author of submission                              | `SubmitInformationRequest`| `String`             |
| /submission/best                |     POST    | Change submission, which will participant in tournament  | `SubmitInformationRequest`| Just http status     |
| /submission/ws                  |     WS      | Subscribe u to ALL notification(submissions and execute) | Wait until get token.   | AUTH_SUCCESS/AUTH_FAILED                        |
| /map/create                     |     POST    | Create new map                                           | `MapCraeteRequest`      | `Map.Public`           |
| /map/all                            |     GET     | Get all maps                                             |  none     | `[Map.Public]`         |
| /map                            |     GET     | Get specific map by id                                             |  `MapDeleteRequest`      | `String`         |
| /battle/create                  |     POST    | Create new battle                                        | `BattleRequest`         | `Battle.New`           |
| /battle/add_run                 |     POST    | Add new game run to battle. If battle is started - Error | `AddGameRun`            | `GameRun.Public`       |
| /battle/run_vis                 |     GET    | Return game run vis file  | `GameRunRequest`            | `String`       |
| /battle/start                   |     POST     | Start already configured battle                          | `StartRequest`          | Just http status       |
| /battle/all                     |     GET     | Return all battles                                       | none                    | `[Battle.Short]`       |
| /battle                         |     GET     | Return battle by id                                      | `GetBattleRequest`      | `Battle.Public `       |
| /battle/status                         |     GET     | Return testing status                        | none      | Http status: imATeapot if suspended, otherwise ok        |
| /tournament/create              |     POST     | Create new tounament, if it possible                     | `TournamentCreateRequest`      |   `Tournament.New` |

## Websocket protocol
### Auth state
Websocket wait for user auth token, after get in send one of messages AUTH_SUCCESS/AUTH_FAILED/TOO_EARLY. If AUTH_SUCCESS was send state will change to comunication, otherwise websocket will close
### Comunication state
In that state websocket have no reaction for user messages. Websocket can send 4 types of message:
* SUSPEND -- testing is suspended
* CONTINUE -- testing is continued
* :submission_id :verdict, where submission_id is 6-digit id of submission, what was sent for compiling and verdict is ok or failed, depends on compilation process result
* :run_id :scores -- where ren_id is integer id of game run and scores is several doubles -- score for each of players

**Be careful -- each same message can be sent as many times as server like :trollface:**
