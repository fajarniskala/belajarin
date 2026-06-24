import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Hai, Selamat Belajar ✨",
                              style: TextStyle(
                                color: Colors.white54,
                                fontWeight: FontWeight(500),
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              "Andi Pratama",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight(800),
                                fontSize: 32,
                              ),
                            ),
                          ],
                        ),

                        Column(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.yellow[600],
                                borderRadius: BorderRadius.all(
                                  Radius.circular(80),
                                ),
                                border: Border.all(
                                  color: Colors.white,
                                  style: BorderStyle.solid,
                                  width: 4,
                                  strokeAlign: BorderSide.strokeAlignOutside,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  "A",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight(900),
                                    fontSize: 32,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CardAchiev(
                          icons: Icons.star,
                          colors: Colors.amber,
                          values: "450",
                          desc: "Total Poin",
                        ),
                        CardAchiev(
                          icons: Icons.workspace_premium,
                          colors: Colors.brown.shade200,
                          values: "7",
                          desc: "Badge",
                        ),
                        CardAchiev(
                          icons: Icons.local_fire_department,
                          colors: Colors.amber.shade900,
                          values: "5",
                          desc: "Hari Streak",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 80),

            Padding(
              padding: const EdgeInsets.only(left: 30, right: 30),
              child: Column(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.menu_book,
                            color: Colors.blue[900],
                            size: 24,
                          ),

                          SizedBox(width: 10),

                          Text(
                            "Lanjut Membaca",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 24,
                              fontWeight: FontWeight(800),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 20),

                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),

                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Image.asset("../assets/book-img.png"),

                              SizedBox(width: 16),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Si Kancil dan Buaya",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight(800),
                                        fontSize: 24,
                                      ),
                                    ),

                                    SizedBox(height: 8),

                                    Text(
                                      "Terakhir dibaca 2 jam lalu",
                                      style: TextStyle(
                                        color: Colors.black26,
                                        fontWeight: FontWeight(500),
                                        fontSize: 16,
                                      ),
                                    ),

                                    ClipRRect(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10),
                                      ),
                                      child: LinearProgressIndicator(
                                        value: 0.5,
                                        backgroundColor: Colors.grey[300],
                                        valueColor: AlwaysStoppedAnimation(
                                          Colors.blue,
                                        ),
                                        minHeight: 10,
                                      ),
                                    ),

                                    SizedBox(height: 8),

                                    Text(
                                      "Halaman 24 dari 80 (30%)",
                                      style: TextStyle(
                                        color: Colors.black26,
                                        fontWeight: FontWeight(500),
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(height: 8),

                                    ElevatedButton(
                                      onPressed: () {},
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            "Lanjutkan Membaca",
                                            style: TextStyle(
                                              color: Colors.blue[900],
                                              fontWeight: FontWeight(800),
                                              fontSize: 16,
                                            ),
                                          ),

                                          Icon(
                                            Icons.play_arrow,
                                            color: Colors.blue[900],
                                            size: 32,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.track_changes,
                            color: Colors.blue[900],
                            size: 24,
                          ),

                          SizedBox(width: 10),

                          Text(
                            "Kategori Belajar",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 24,
                              fontWeight: FontWeight(800),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 20),

                      GridView.count(
                        shrinkWrap: true,
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        physics: NeverScrollableScrollPhysics(),
                        mainAxisExtent: 160,
                        children: [
                          CardModule(
                            icons: Icons.calculate,
                            colorsIc: Colors.red.shade400,
                            colors: Colors.red.shade100,
                            colorsTitle: Colors.red.shade400,
                            colorsCount: Colors.red.shade300,
                            title: "Matematika",
                            count: "12 modul",
                          ),
                          CardModule(
                            icons: Icons.biotech,
                            colorsIc: Colors.green.shade400,
                            colors: Colors.green.shade100,
                            colorsTitle: Colors.green.shade400,
                            colorsCount: Colors.green.shade300,
                            title: "IPA",
                            count: "9 modul",
                          ),
                          CardModule(
                            icons: Icons.public,
                            colorsIc: Colors.blue.shade800,
                            colors: Colors.indigo.shade100,
                            colorsTitle: Colors.indigo.shade400,
                            colorsCount: Colors.indigo.shade300,
                            title: "IPS",
                            count: "21 modul",
                          ),
                          CardModule(
                            icons: Icons.book_online_rounded,
                            colorsIc: Colors.orange.shade400,
                            colors: Colors.orange.shade100,
                            colorsTitle: Colors.orange.shade400,
                            colorsCount: Colors.orange.shade300,
                            title: "B.Indonesia",
                            count: "11 modul",
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class CardModule extends StatelessWidget {
  final IconData icons;
  final String title;
  final String count;
  final Color colors;
  final Color colorsIc;
  final Color colorsTitle;
  final Color colorsCount;

  const CardModule({
    super.key,
    required this.icons,
    required this.title,
    required this.count,
    required this.colors,
    required this.colorsIc,
    required this.colorsTitle,
    required this.colorsCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colors,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),

      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icons, size: 32, color: colorsIc),

            SizedBox(height: 8),

            Text(
              title,
              style: TextStyle(
                color: colorsTitle,
                fontSize: 24,
                fontWeight: FontWeight(800),
              ),
            ),
            SizedBox(height: 8),

            Text(
              count,
              style: TextStyle(
                color: colorsCount,
                fontSize: 16,
                fontWeight: FontWeight(500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CardAchiev extends StatelessWidget {
  final String values;
  final String desc;
  final IconData icons;
  final Color colors;

  const CardAchiev({
    super.key,
    required this.values,
    required this.desc,
    required this.icons,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white38,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icons, color: colors, size: 32),

                SizedBox(width: 6),
                Text(
                  values,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight(800),
                    fontSize: 24,
                  ),
                ),
              ],
            ),

            Text(
              desc,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight(800),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
