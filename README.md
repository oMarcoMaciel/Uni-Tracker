# 🎓 UniTracker - Controle Acadêmico

![Flutter](https://img.shields.io/badge/Flutter-3.0%2B-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Status](https://img.shields.io/badge/Status-Em%20Desenvolvimento-yellow?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

Um aplicativo mobile moderno desenvolvido em **Flutter** para gerenciamento de vida acadêmica. O UniTracker permite que estudantes organizem seus períodos, acompanhem médias, controlem faltas e gerenciem avaliações de forma visual e intuitiva.

---

## ✨ Funcionalidades (Implementadas)

* **🎨 UI/UX Moderna:** Interface Dark Mode com acentos em Verde Neon focada em usabilidade.
* **📊 Dashboard:** Visão geral da Média Geral e Progresso do Semestre atual.
* **📅 Gestão de Períodos:** Histórico completo de semestres (passados e atual).
* **📚 Controle de Disciplinas:**
    * Monitoramento visual de faltas (com alertas de risco).
    * Cálculo de média por disciplina.
    * Organização por cores e ícones.
* **📝 Detalhes Acadêmicos:** Registro de provas, trabalhos e anotações rápidas.
* **👤 Perfil do Aluno:** Visualização de CR (GPA), curso e dados institucionais.

---

## 🛠️ Tecnologias Utilizadas

* **Linguagem:** Dart
* **Framework:** Flutter
* **Gerenciamento de Pacotes:**
    * `google_fonts`: Tipografia (Poppins/Montserrat).
    * `flutter_svg`: Renderização de ícones vetoriais.
    * `provider`: Injeção de dependência e gerenciamento de estado (preparado).

---

## 📂 Estrutura do Projeto

O projeto segue uma arquitetura limpa e modular baseada em funcionalidades:

```text
lib/
├── core/
│   ├── theme/          # Paleta de cores (AppColors) e Estilos
│   └── constants/      # Configurações globais
├── screens/
│   ├── home/           # Dashboard e Menu Principal
│   ├── periods/        # Listagem e Detalhes de Semestres
│   ├── subject/        # Controle de Disciplinas e Notas
│   ├── profile/        # Perfil do Usuário
│   └── settings/       # Configurações do App
├── widgets/            # Componentes reutilizáveis (Cards, Inputs)
└── main.dart           # Ponto de entrada
