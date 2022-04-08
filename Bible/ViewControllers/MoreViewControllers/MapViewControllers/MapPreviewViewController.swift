//
//  MapPreviewViewController.swift
//  Bible
//
//  Created by Bogdan Grozian on 07.03.2022.
//

import UIKit

final class MapPreviewViewController: UITableViewController {
    
    var additionalInformation: [String]?
    let mapType: MapType
    init(mapType: MapType) {
        self.mapType = mapType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(MapTableViewCell.nib, forCellReuseIdentifier: MapTableViewCell.identifier)
        tableView.register(TextTableViewCell.self, forCellReuseIdentifier: TextTableViewCell.identifier)
        getAdditionalInfo()
        tableView.reloadData()
    }
}

// MARK: - Data Source
extension MapPreviewViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return additionalInformation == nil ? 1 : 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return additionalInformation?.count ?? 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: MapTableViewCell.identifier, for: indexPath)
            if let cell = cell as? MapTableViewCell {
                cell.configure(image: UIImage(named: mapType.imageName))
            }
        } else {
            cell = TextTableViewCell()
            if let cell = cell as? TextTableViewCell {
                cell.label.text = additionalInformation?[indexPath.row]
            }
        }
        cell.selectionStyle = .none
        return cell
    }
}

extension MapPreviewViewController {
    private func getAdditionalInfo() {
        switch mapType {
        case .israilsExodusFromEgyptAndEntryIntoCananan:
            additionalInformation = ["Rameses Israel was thrust out of Egypt (Ex. 12; Num. 33:5).",
            "Succoth After the Hebrews left this first campsite, the Lord attended them in a cloud by day and in a pillar of fire by night (Ex. 13:20–22).",
            "Pi-hahiroth Israel passed through the Red Sea (Ex. 14; Num. 33:8).",
            "Marah The Lord healed the waters of Marah (Ex. 15:23–26).",
            "Elim Israel camped by 12 springs (Ex. 15:27).",
            "Wilderness of Sin The Lord sent manna and quail to feed Israel (Ex. 16).",
            "Rephidim Israel fought with Amalek (Ex. 17:8–16).",
            "Mount Sinai (Mount Horeb or Jebel Musa) The Lord revealed the Ten Commandments (Ex. 19–20).",
            "Sinai Wilderness Israel constructed the tabernacle (Ex. 25–30).",
            "Wilderness Camps Seventy elders were called to help Moses govern the people (Num. 11:16–17).",
            "Ezion-geber Israel passed through the lands of Esau and Ammon in peace (Deut. 2).",
            "Kadesh-barnea Moses sent spies into the promised land; Israel rebelled and failed to enter the land; Kadesh served as the main camp of Israel for many years (Num. 13:1–3, 17–33; 14; 32:8; Deut. 2:14).",
            "Eastern Wilderness Israel avoided conflict with Edom and Moab (Num. 20:14–21; 22–24).",
            "Arnon River Israel destroyed the Amorites who fought against them (Deut. 2:24–37).",
            "Mount Nebo Moses viewed the promised land (Deut. 34:1–4).",
            "Moses delivered his last three sermons (Deut. 1–32).",
            "Plains of Moab The Lord told Israel to divide the land and dispossess the inhabitants (Num. 33:50–56).",
            "Jordan River Israel crossed the Jordan River on dry ground. Near Gilgal, stones from the bottom of the Jordan River were placed as a monument of Jordan’s waters being divided (Josh. 3:1–5:1).",
            "Jericho The children of Israel captured and destroyed the city (Josh. 6)."]
        case .oldTestament:
            additionalInformation = ["Mount Ararat The traditional site where Noah’s ark landed (Gen. 8:4). The exact location is unknown.",
            "Ur First residence of Abraham, near the mouth of the Euphrates, where he was almost a victim of human sacrifice, saw the angel of Jehovah, and received the Urim and Thummim (Gen. 11:28–12:1; Abr. 1; 3:1). (Note also a possible alternate site for Ur in northern Mesopotamia.)",
            "Babylon, Babel (Shinar) First settled by Cush, the son of Ham, and by Nimrod. Area of origin of Jaredites at the time of the Tower of Babel in the plains of Shinar. Later provincial capital of Babylonia and residence of Babylonian kings, including Nebuchadnezzar who carried many Jews captive to this city following the destruction of Jerusalem (587 B.C.). The Jews remained in captivity in Babylon for 70 years until the time of King Cyrus, who permitted the Jews to return to Jerusalem to rebuild the temple. Daniel the prophet also resided here under Nebuchadnezzar, Belshazzar, and Darius Ⅰ (Gen. 10:10; 11:1–9; 2 Kgs. 24–25; Jer. 27:1–29:10; Ezek. 1:1; Dan. 1–12; Omni 1:22; Ether 1:33–43).",
            "Shushan (Susa) Capital city of the Persian Empire under the reigns of Darius Ⅰ (Darius the Great), Xerxes (Ahasuerus), and Artaxerxes. Residence of Queen Esther, whose courage and faith saved the Jews. Daniel and later Nehemiah served here (Neh. 1:1; 2:1; Esth. 1:1; Dan. 8:2).",
            "Plain of Dura Shadrach, Meshach, and Abed-nego were cast into a fiery furnace when they refused to worship a golden image created by Nebuchadnezzar; the Son of God preserved them, and they emerged from the furnace unharmed (Dan. 3).",
            "Assyria Asshur was Assyria’s first capital, followed by Nineveh. Assyrian rulers Shalmaneser Ⅴ and Sargon Ⅱ conquered the Northern Kingdom of Israel and carried away the ten tribes captive in 721 B.C. (2 Kgs. 14–15; 17–19). Assyria was a threat to Judah until 612 B.C., when Assyria was conquered by Babylon.",
            "Nineveh The capital of Assyria. Assyria attacked the land of Judah during the reign of Hezekiah and the ministry of the prophet Isaiah. Jerusalem, the capital city of Judah, was miraculously saved when an angel smote 185,000 Assyrian soldiers (2 Kgs. 19:32–37). The Lord told the prophet Jonah to call this city to repentance (Jonah 1:2; 3:1–4).",
            "Haran Abraham settled here for a time before going to Canaan. Abraham’s father and brother remained here. Rebekah (Isaac’s wife), and Rachel, Leah, Bilhah, and Zilpah (Jacob’s wives), came from this area (Gen. 11:31–32; 24:10; 29:4–6; Abr. 2:4–5).",
            "Carchemish Pharaoh Necho was defeated here by Nebuchadnezzar, which ended Egyptian power in Canaan (2 Chr. 35:20–36:6).",
            "Sidon This city was founded by Sidon, a grandson of Ham, and is the northernmost Canaanite city (Gen. 10:15–20). It was the home of Jezebel, who introduced Baal worship into Israel (1 Kgs. 16:30–33).",
            "Tyre This was an important commercial and seaport city in Syria. Hiram of Tyre sent cedar and gold and workmen to aid Solomon in building his temple (1 Kgs. 5:1–10, 18; 9:11).",
           "Damascus Abraham rescued Lot near here. It was the chief city of Syria. During King David’s reign, the Israelites conquered the city. Elijah anointed Hazael to be king over Damascus (Gen. 14:14–15; 2 Sam. 8:5–6; 1 Kgs. 19:15).",
            "Canaan Abraham, Isaac, Jacob, and their descendants were given this land for an everlasting possession (Gen. 17:8; 28).",
            "Mount Sinai (Horeb) The Lord spoke to Moses from a burning bush (Ex. 3:1–2). Moses was given the Law and the Ten Commandments (Ex. 19–20). The Lord spoke to Elijah in a still, small voice (1 Kgs. 19:8–12).",
            "Ezion-geber King Solomon built a “navy of ships” in Ezion-geber (1 Kgs. 9:26). Probably at this port the queen of Sheba, after hearing of the fame of Solomon, landed to see him (1 Kgs. 10:1–13).",
            "Egypt Abraham traveled here because of a great famine in Ur (Abr. 2:1, 21). The Lord told Abraham to teach the Egyptians what He had revealed to him (Abr. 3:15). After Joseph’s brothers sold him into slavery (Gen. 37:28), Joseph became a ruler of Potiphar’s house here. He was cast into prison. He interpreted Pharaoh’s dream and was given a position of authority in Egypt. Joseph and his brothers were brought together. Jacob and his family moved here (Gen. 39–46). The children of Israel dwelt in Goshen during their sojourn in Egypt (Gen. 47:6).",
            "The Israelites multiplied “and waxed exceeding mighty”; they were then placed in bondage by the Egyptians (Ex. 1:7–14). After a series of plagues Pharaoh allowed Israel to leave Egypt (Ex. 12:31–41). Jeremiah was taken to Egypt (Jer. 43:4–7).",
            "Caphtor (Crete) The ancient land of the Minoans."]
        case .canaanInOldTestamentTimes:
            additionalInformation = ["Dan (Laish) Jeroboam set up a golden calf for the Northern Kingdom to worship (1 Kgs. 12:26–33). Dan was the northern limit of ancient Israel.",
            "Mount Carmel Elijah challenged the prophets of Baal and opened the heavens for rain (1 Kgs. 18:17–46).",
            "Megiddo A place of many battles (Judg. 4:13–16; 5:19; 2 Kgs. 23:29; 2 Chr. 35:20–23). Solomon raised a levy to build up Megiddo (1 Kgs. 9:15). King Josiah of Judah was mortally wounded in a battle against Pharaoh Necho of Egypt (2 Kgs. 23:29–30). At the Second Coming of the Lord, a great and final conflict will take place in the Jezreel Valley as part of the battle of Armageddon (Joel 3:14; Rev. 16:16; 19:11–21). The name Armageddon is a Greek transliteration from the Hebrew Har Megiddon, or Mountain of Megiddo.",
            "Jezreel The name of a city in the largest and most fertile valley of Israel by the same name. The kings of the Northern Kingdom built a palace here (2 Sam. 2:8–9; 1 Kgs. 21:1–2). Wicked Queen Jezebel lived and died here (1 Kgs. 21; 2 Kgs. 9:30).",
            "Beth-shan Israel faced the Canaanites here (Josh. 17:12–16). Saul’s body was fastened to the walls of this fortress (1 Sam. 31:10–13).",
            "Dothan Joseph was sold into slavery by his brothers (Gen. 37:17, 28; 45:4). Elisha had a vision of the mountain full of horses and chariots (2 Kgs. 6:12–17).",
            "Samaria The Northern Kingdom’s capital (1 Kgs. 16:24–29). King Ahab built a temple to Baal (1 Kgs. 16:32–33). Elijah and Elisha ministered (1 Kgs. 18:2; 2 Kgs. 6:19–20). In 721 B.C. the Assyrians conquered it, completing the capture of the ten tribes (2 Kgs. 18:9–10).",
            "Shechem Abraham built an altar (Gen. 12:6–7). Jacob lived near here. Simeon and Levi massacred all the males of this city (Gen. 34:25). Joshua’s encouragement to “choose … this day” to serve God came in Shechem (Josh. 24:15). Here Jeroboam established the first capital of the Northern Kingdom (1 Kgs. 12).",
            "Mount Ebal and Mount Gerizim Joshua divided Israel on these two mounts—the blessings of the law were proclaimed from Mount Gerizim, while the cursings came from Mount Ebal (Josh. 8:33). The Samaritans later built a temple on Gerizim (2 Kgs. 17:32–33).",
            "Penuel (Peniel) Here Jacob wrestled all night with a messenger of the Lord (Gen. 32:24–32). Gideon destroyed a Midianite fortress (Judg. 8:5, 8–9).",
            "Joppa Jonah sailed from here toward Tarshish to avoid his mission to Nineveh (Jonah 1:1–3).",
            "Shiloh During the time of the Judges, Israel’s capital and the tabernacle were located here (1 Sam. 4:3–4).",
            "Bethel (Luz) Here Abraham separated from Lot (Gen. 13:1–11) and had a vision (Gen. 13; Abr. 2:19–20). Jacob had a vision of a ladder reaching into heaven (Gen. 28:10–22). The tabernacle was located here for a time (Judg. 20:26–28). Jeroboam set up a golden calf for the Northern Kingdom to worship (1 Kgs. 12:26–33).",
            "Gibeon Hivite people from here tricked Joshua into a treaty (Josh. 9). The sun stood still while Joshua won a battle (Josh. 10:2–13). This was also a temporary site of the tabernacle (1 Chr. 16:39).",
            "Gaza, Ashdod, Ashkelon, Ekron, Gath (the five cities of the Philistines) From these cities the Philistines often made war on Israel.",
            "Bethlehem Rachel was buried nearby (Gen. 35:19). Ruth and Boaz lived here (Ruth 1:1–2; 2:1, 4). It was called the city of David (Luke 2:4).",
            "Hebron Abraham (Gen. 13:18), Isaac, Jacob (Gen. 35:27), David (2 Sam. 2:1–4), and Absalom (2 Sam. 15:10) lived here. This was the first capital of Judah under King David (2 Sam. 2:11). It is believed that Abraham, Sarah, Isaac, Rebekah, Jacob, and Leah were buried here in the cave of Machpelah (Gen. 23:17–20; 49:31, 33).",
            "En-gedi David hid from Saul and spared Saul’s life (1 Sam. 23:29–24:22).",
            "Gerar Abraham and Isaac lived here for a time (Gen. 20–22; 26).",
            "Beersheba Abraham dug a well here and covenanted with Abimelech (Gen. 21:31). Isaac saw the Lord (Gen. 26:17, 23–24), and Jacob lived here (Gen. 35:10; 46:1).",
            "Sodom and Gomorrah Lot chose to live in Sodom (Gen. 13:11–12; 14:12). God destroyed Sodom and Gomorrah because of wickedness (Gen. 19:24–26). Jesus later used these cities as symbols of wickedness (Matt. 10:15)."]
        case .holeLandNewTestamentTimes:
            additionalInformation = ["Tyre and Sidon Jesus compared Chorazin and Bethsaida to Tyre and Sidon (Matt. 11:20–22). He healed the daughter of a Gentile woman (Matt. 15:21–28).",
            "Mount of Transfiguration Jesus was transfigured before Peter, James, and John, and they received the keys of the kingdom (Matt. 17:1–13). (Some believe the Mount of Transfiguration to be Mount Hermon; others believe it to be Mount Tabor.)",
            "Caesarea Philippi Peter testified that Jesus is the Christ and was promised the keys of the kingdom (Matt. 16:13–20). Jesus foretold His own death and Resurrection (Matt. 16:21–28).",
            "Region of Galilee Jesus spent most of His life and ministry in Galilee (Matt. 4:23–25). Here He gave the Sermon on the Mount (Matt. 5–7); healed a leper (Matt. 8:1–4); and chose, ordained, and sent forth the Twelve Apostles, of whom only Judas Iscariot was apparently not Galilean (Mark 3:13–19). In Galilee the risen Christ appeared to the Apostles (Matt. 28:16–20).",
            "Sea of Galilee, later called Sea of Tiberias Jesus taught from Peter’s boat (Luke 5:1–3) and called Peter, Andrew, James, and John to be fishers of men (Matt. 4:18–22; Luke 5:1–11). He also stilled the tempest (Luke 8:22–25), taught parables from a boat (Matt. 13), walked on the sea (Matt. 14:22–32), and appeared to His disciples after His Resurrection (John 21).",
            "Bethsaida Peter, Andrew, and Philip were born in Bethsaida (John 1:44). Jesus went away privately with the Apostles near Bethsaida. The multitudes followed Him, and He fed the 5,000 (Luke 9:10–17; John 6:1–14). Here Jesus healed a blind man (Mark 8:22–26).",
            "Capernaum This was Peter’s home (Matt. 8:5, 14). In Capernaum, which Matthew called Jesus’ “own city,” Jesus healed a paralytic (Matt. 9:1–7; Mark 2:1–12), cured a centurion’s servant, healed the mother of Peter’s wife (Matt. 8:5–15), called Matthew to be one of His Apostles (Matt. 9:9), opened blind eyes, cast out a devil (Matt. 9:27–33), healed a man’s withered hand on the Sabbath (Matt. 12:9–13), gave the bread of life discourse (John 6:22–65), and agreed to pay taxes, telling Peter to get the money from a fish’s mouth (Matt. 17:24–27).",
            "Magdala This was the home of Mary Magdalene (Mark 16:9). Jesus came here after feeding the 4,000 (Matt. 15:32–39), and the Pharisees and Sadducees requested that He show them a sign from heaven (Matt. 16:1–4).",
            "Cana Jesus turned water into wine (John 2:1–11) and healed a nobleman’s son who was at Capernaum (John 4:46–54). Cana was also the home of Nathanael (John 21:2).",
            "Nazareth The annunciations to Mary and Joseph took place in Nazareth (Matt. 1:18–25; Luke 1:26–38; 2:4–5). After returning from Egypt, Jesus spent His childhood and youth here (Matt. 2:19–23; Luke 2:51–52), announced that He was the Messiah, and was rejected by His own (Luke 4:14–32).",
            "Jericho Jesus gave sight to a blind man (Luke 18:35–43). He also dined with Zacchaeus, “chief among the publicans” (Luke 19:1–10).",
            "Bethabara John the Baptist testified that he was “the voice of one crying in the wilderness” (John 1:19–28). John baptized Jesus in the Jordan River and testified that Jesus is the Lamb of God (John 1:28–34).",
            "Wilderness of Judea John the Baptist preached in this wilderness (Matt. 3:1–4), where Jesus fasted 40 days and was tempted (Matt. 4:1–11).",
            "Emmaus The risen Christ walked on the road to Emmaus with two of His disciples (Luke 24:13–32).",
            "Bethphage Two disciples brought Jesus a colt on which He began His triumphal entry into Jerusalem (Matt. 21:1–11).",
            "Bethany This was the home of Mary, Martha, and Lazarus (John 11:1). Mary heard Jesus’ words, and Jesus spoke to Martha of choosing the “good part” (Luke 10:38–42); Jesus raised Lazarus from the dead (John 11:1–44); and Mary anointed Jesus’ feet (Matt. 26:6–13; John 12:1–8).",
            "Bethlehem Jesus was born and was laid in a manger (Luke 2:1–7); angels heralded to the shepherds the birth of Jesus (Luke 2:8–20); wise men were directed by a star to Jesus (Matt. 2:1–12); and Herod slew the children (Matt. 2:16–18)."]
        case .jerusalemJesusTime:
            additionalInformation = ["Golgotha A possible site for Jesus’ crucifixion (Matt. 27:33–37).",
            "Garden Tomb A possible site for the tomb in which the body of Jesus was placed (John 19:38–42). The risen Christ appeared to Mary Magdalene in the garden outside His tomb (John 20:1–17).",
            "Antonia Fortress Jesus may have been accused, condemned, mocked, and scourged at this site (John 18:28–19:16). Paul was arrested and recounted the story of his conversion (Acts 21:31–22:21).",
            "Pool of Bethesda Jesus healed an invalid on the Sabbath (John 5:2–9).",
            "Temple Gabriel promised Zacharias that Elisabeth would bear a son (Luke 1:5–25). The veil of the temple was rent at the death of the Savior (Matt. 27:51).",
            "Solomon’s Porch Jesus proclaimed that He was the Son of God. The Jews attempted to stone Him (John 10:22–39). Peter preached repentance after healing a lame man (Acts 3:11–26).",
            "Gate Beautiful Peter and John healed a lame man (Acts 3:1–10).",
            "Pinnacle of the Temple Jesus was tempted by Satan (Matt. 4:5–7). (A likely location for this event.)",
            "Holy Mount (unspecified locations)",
            "Tradition holds that here Abraham built an altar for the sacrifice of Isaac (Gen. 22:9–14).",
            "Solomon built the temple (1 Kgs. 6:1–10; 2 Chr. 3:1).",
            "The Babylonians destroyed the temple in about 587 B.C. (2 Kgs. 25:8–9).",
            "Zerubbabel rebuilt the temple in about 515 B.C. (Ezra 3:8–10; 5:2; 6:14–16).",
            "Herod expanded the temple plaza and rebuilt the temple starting in 17 B.C. Jesus was presented as a baby (Luke 2:22–39).",
            "At age 12, Jesus taught in the temple (Luke 2:41–50).",
            "Jesus cleansed the temple (Matt. 21:12–16; John 2:13–17).",
            "Jesus taught in the temple on several occasions (Matt. 21:23–23:39; John 7:14–8:59).",
            "The Romans under Titus destroyed the temple in A.D. 70.",
            "Garden of Gethsemane Jesus suffered, was betrayed, and was arrested (Matt. 26:36–46; Luke 22:39–54).",
            "Mount of Olives",
            "Jesus foretold the destruction of Jerusalem and the temple. He also spoke of the Second Coming (Matt. 24:3–25:46; see also JS—M).",
            "From here Jesus ascended into heaven (Acts 1:9–12).",
            "On October 24, 1841, Elder Orson Hyde dedicated the Holy Land for the return of the children of Abraham.",
            "Gihon Spring Solomon was anointed king (1 Kgs. 1:38–39). Hezekiah had a tunnel dug to bring water from the spring into the city (2 Chr. 32:30).",
            "Water Gate Ezra read and interpreted the law of Moses to the people (Neh. 8:1–8).",
            "Hinnom Valley The false god Molech was worshipped, which included child sacrifice (2 Kgs. 23:10; 2 Chr. 28:3).",
            "House of Caiaphas Jesus was taken before Caiaphas (Matt. 26:57–68). Peter denied that he knew Jesus (Matt. 26:69–75).",
            "Upper Room The traditional location where Jesus ate the Passover meal and instituted the sacrament (Matt. 26:20–30). He washed the feet of the Apostles (John 13:4–17) and taught them (John 13:18–17:26).",
            "Herod’s Palace Christ was taken before Herod, possibly at this location (Luke 23:7–11).",
            "Jerusalem (unspecified locations)",
            "Melchizedek ruled as king of Salem (Gen. 14:18).",
            "King David captured the city from the Jebusites (2 Sam. 5:7; 1 Chr. 11:4–7).",
            "The city was destroyed by the Babylonians in about 587 B.C. (2 Kgs. 25:1–11).",
            "The Holy Ghost filled many on the day of Pentecost (Acts 2:1–4).",
            "Peter and John were arrested and brought before the council (Acts 4:1–23).",
            "Ananias and Sapphira lied to the Lord and died (Acts 5:1–10).",
            "Peter and John were arrested, but an angel delivered them from prison (Acts 5:17–20).",
            "The Apostles chose seven men to assist them (Acts 6:1–6).",
            "Stephen’s testimony to the Jews was rejected, and he was stoned to death (Acts 6:8–7:60).",
            "James was martyred (Acts 12:1–2).",
            "An angel freed Peter from prison (Acts 12:5–11).",
            "The Apostles decided the issue of circumcision (Acts 15:5–29).",
            "The Romans under Titus destroyed the city in A.D. 70."]
        case .paulsJourneys:
            additionalInformation = ["Gaza Philip preached of Christ and baptized an Ethiopian eunuch on his way to Gaza (Acts 8:26–39).",
            "Jerusalem See map 12 for events in Jerusalem.",
            "Joppa Peter received a vision that God grants the gift of repentance to the Gentiles (Acts 10; 11:5–18). Peter raised Tabitha from the dead (Acts 9:36–42).",
            "Samaria Philip ministered in Samaria (Acts 8:5–13), and Peter and John later taught here (Acts 8:14–25). After they conferred the gift of the Holy Ghost, Simon the sorcerer sought to buy this gift from them (Acts 8:9–24).",
            "Caesarea Here, after an angel ministered to a centurion named Cornelius, Peter allowed him to be baptized (Acts 10). Here Paul made his defense before Agrippa (Acts 25–26; see also JS—H 1:24–25).",
            "Damascus Jesus appeared to Saul (Acts 9:1–7). After Ananias restored Saul’s sight, Saul was baptized and began his ministry (Acts 9:10–27).",
            "Antioch (in Syria) Here disciples were first called Christians (Acts 11:26). Agabus prophesied famine (Acts 11:27–28). Great dissension arose at Antioch concerning circumcision (Acts 14:26–28; 15:1–9). In Antioch Paul began his second mission with Silas, Barnabas, and Judas Barsabas (Acts 15:22, 30, 35).",
            "Tarsus Paul’s hometown; Paul was sent here by the Brethren to protect his life (Acts 9:29–30).",
            "Cyprus After being persecuted, some Saints fled to this island (Acts 11:19). Paul traveled through Cyprus on his first missionary journey (Acts 13:4–5), as did Barnabas and Mark later (Acts 15:39).",
            "Paphos Paul cursed a sorcerer here (Acts 13:6–11).",
            "Derbe Paul and Barnabas preached the gospel in this city (Acts 14:6–7, 20–21).",
            "Lystra When Paul healed a cripple, he and Barnabas were hailed as gods. Paul was stoned and presumed dead but revived and continued preaching (Acts 14:6–21). Home of Timothy (Acts 16:1–3).",
            "Iconium On their first mission, Paul and Barnabas preached here and were threatened with stoning (Acts 13:51–14:7).",
            "Laodicea and Colosse Laodicea is one of the branches of the Church that Paul visited and received letters from (Col. 4:16). It is also one of the seven cities listed in the book of Revelation (the others are Ephesus, Smyrna, Pergamos, Thyatira, Sardis, and Philadelphia; see Rev. 1:11). Colosse lies 11 miles (18 kilometers) to the east of Laodicea. Paul wrote to the Saints who lived here.",
            "Antioch (in Pisidia) On their first mission, Paul and Barnabas taught the Jews that Christ came of the seed of David. Paul offered the gospel to Israel, then to the Gentiles. Paul and Barnabas were persecuted and expelled (Acts 13:14–50).",
            "Miletus While here on his third mission, Paul warned the elders of the Church that “grievous wolves” would enter the flock (Acts 20:29–31).",
            "Patmos John was a prisoner on this island when he received the visions now contained in the book of Revelation (Rev. 1:9).",
            "Ephesus Apollos preached here with power (Acts 18:24–28). Paul, on his third mission, taught in Ephesus for two years, converting many people (Acts 19:10, 18). Here he conferred the gift of the Holy Ghost by the laying on of hands (Acts 19:1–7) and performed many miracles, including casting out evil spirits (Acts 19:8–21). Here worshippers of Diana raised a tumult against Paul (Acts 19:22–41). Part of the book of Revelation was addressed to the Church at Ephesus (Rev. 1:11).",
            "Troas While Paul was here on his second missionary journey, he saw a vision of a man in Macedonia asking for help (Acts 16:9–12). While here on his third mission, Paul raised Eutychus from the dead (Acts 20:6–12).",
            "Philippi Paul, Silas, and Timothy converted a woman named Lydia, cast out an evil spirit, and were beaten (Acts 16:11–23). They received divine help to escape prison (Acts 16:23–26).",
            "Athens Paul, while on his second mission to Athens, preached at Mars’ Hill (Areopagus) about the “unknown god” (Acts 17:22–34).",
            "Corinth Paul went to Corinth on his second mission, where he stayed with Aquila and Priscilla. He preached here and baptized many people (Acts 18:1–18). From Corinth, Paul wrote his epistle to the Romans.",
            "Thessalonica Paul preached here during his second missionary journey. His missionary group departed for Berea after the Jews threatened their safety (Acts 17:1–10).",
            "Berea Paul, Silas, and Timothy found noble souls to teach during Paul’s second missionary journey. The Jews from Thessalonica followed and persecuted them (Acts 17:10–13).",
            "Macedonia Paul taught here on his second and third journeys (Acts 16:9–40; 19:21). Paul praised the generosity of the Macedonian Saints, who gave to him and to the poor Saints at Jerusalem (Rom. 15:26; 2 Cor. 8:1–5; 11:9).",
            "Melita Paul was shipwrecked on this island on his way to Rome (Acts 26:32; 27:1, 41–44). He was unharmed by a snakebite and healed many who were sick on Melita (Acts 28:1–9).",
            "Rome Paul preached here for two years under house arrest (Acts 28:16–31). He also wrote epistles, or letters, to the Ephesians, Philippians, and Colossians and to Timothy and Philemon while imprisoned in Rome. Peter wrote his first epistle from “Babylon,” which was probably Rome, soon after Nero’s persecutions of the Christians in A.D. 64. It is generally believed that Peter and Paul were martyred here."]
        default:
            break
        }
    }
}
