import 'package:flutter/material.dart';
import 'package:photoflow/screen/agenda/agendahome.dart';
import 'package:photoflow/screen/settings/settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  bool _isExtended = false; // Controla o estado do NavigationRail
  int _selectedIndex = 0; // Controla qual tela está selecionada

  // Suas páginas/painéis
  final List<Widget> _pages = [
    AgendaPanel(),
    SettingsPage(),
    // AgendaPanel(), // Seu painel de Agenda
    // BookingListPanel(), // Seu painel de Lista de Agendamentos
    // ReportPanel(), // Seu painel de Relatórios
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Photoflow Admin'),
      //   leading: IconButton(
      //     // Botão para expandir/recuar o NavigationRail
      //     icon: Icon(_isExtended ? Icons.menu_open : Icons.menu),
      //     onPressed: () {
      //       setState(() {
      //         _isExtended = !_isExtended;
      //       });
      //     },
      //   ),
      // ),
      body: Row(
        children: <Widget>[
          NavigationRail(
            selectedIndex: _selectedIndex,
            extended: _isExtended,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: _isExtended
                ? NavigationRailLabelType.none
                : NavigationRailLabelType.selected, // ou .all
            leading: IconButton(
              // Botão para expandir/recuar o NavigationRail
              icon: Icon(_isExtended ? Icons.menu_open : Icons.menu),
              onPressed: () {
                setState(() {
                  _isExtended = !_isExtended;
                });
              },
            ),

            // leading: _isExtended
            //     ? FloatingActionButton(
            //         elevation: 0,
            //         onPressed: () {
            //           // Ação do botão flutuante no topo do NavigationRail expandido
            //         },
            //         child: Icon(Icons.add),
            //       )
            //     : SizedBox(), // Espaço ou ícone quando recuado
            destinations: [
              NavigationRailDestination(
                icon: Icon(Icons.home),
                selectedIcon: Icon(Icons.home_filled),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.groups_2),
                selectedIcon: Icon(Icons.groups_2_outlined),
                label: Text('Clientes'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.calendar_today_sharp),
                selectedIcon: Icon(Icons.calendar_today_outlined),
                label: Text('Agendamentos'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.work),
                selectedIcon: Icon(Icons.work_outlined),
                label: Text('Projetos'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.attach_money_outlined),
                selectedIcon: Icon(Icons.attach_money),
                label: Text('Financeiro'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.edit_document),
                selectedIcon: Icon(Icons.edit_document),
                label: Text('Contratos'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings),
                selectedIcon: Icon(Icons.settings_outlined),
                label: Text('Configurações'),
              ),
            ],
            // Adicione um trailing widget se desejar, como configurações ou logout
            // trailing: Expanded(
            //   child: Align(
            //     alignment: Alignment.bottomCenter,
            //     child: Padding(
            //       padding: const EdgeInsets.only(bottom: 8.0),
            //       child: IconButton(
            //         icon: Icon(Icons.logout),
            //         onPressed: () {
            //           // Ação de logout
            //         },
            //       ),
            //     ),
            //   ),
            // ),
          ),
          VerticalDivider(thickness: 1, width: 1), // Linha divisória
          // Conteúdo principal da página selecionada
          Expanded(
            child: _pages[0],
          ),
        ],
      ),
    );
  }
}
