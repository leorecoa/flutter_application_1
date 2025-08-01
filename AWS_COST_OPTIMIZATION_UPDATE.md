# Otimização de Custos AWS - AgendeMais

## Problemas Identificados

Ao analisar o código do projeto, identificamos que as bibliotecas AWS Amplify estavam sendo importadas, mas não estavam declaradas como dependências no `pubspec.yaml`. Isso causava erros de compilação e também poderia levar a cobranças desnecessárias se as bibliotecas fossem instaladas e utilizadas durante o desenvolvimento.

## Soluções Implementadas

1. **Criação de Mock para o AmplifyService**:
   - Substituímos a implementação real do `AmplifyService` por uma versão mock
   - Removemos as dependências das bibliotecas AWS Amplify
   - Simulamos as operações para permitir o desenvolvimento sem custos

2. **Atualização do pubspec.yaml**:
   - Adicionamos apenas as dependências essenciais
   - Comentamos as dependências do AWS Amplify
   - Documentamos como habilitar o Amplify quando necessário

3. **Configuração de Ambiente**:
   - Mantivemos o `EnvironmentConfig` para controlar o comportamento da aplicação
   - Configuramos para usar emuladores locais em desenvolvimento

## Como Usar

### Durante o Desenvolvimento

O sistema está configurado para funcionar em modo offline durante o desenvolvimento, simulando todas as operações que normalmente seriam realizadas pelos serviços AWS. Isso permite desenvolver e testar sem gerar custos.

### Para Produção

Quando estiver pronto para implantar em produção:

1. Descomente as dependências do AWS Amplify no `pubspec.yaml`
2. Execute `flutter pub get` para instalar as dependências
3. Substitua a implementação mock do `AmplifyService` pela implementação real
4. Configure o `EnvironmentConfig` para modo de produção

## Economia de Custos

Esta abordagem permite economizar custos de:

- **API Gateway**: Sem chamadas durante o desenvolvimento
- **Lambda**: Sem invocações de funções
- **DynamoDB**: Sem operações de leitura/escrita
- **Cognito**: Sem autenticações reais
- **S3**: Sem armazenamento de arquivos
- **Analytics**: Sem envio de eventos

Todos os serviços são simulados localmente, garantindo que você não seja cobrado durante o desenvolvimento.