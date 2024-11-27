FROM node:18-alpine

# Добавляем непривилегированного пользователя
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# задаём рабочую директорию внутри контейнера
WORKDIR /usr/src/app

# копируем package.json и package-lock.json
# из текущей дир-ии в дир-ию контейнера
COPY package*.json ./

# устанавливаем зависимости из файлов и очищаем кеш
RUN npm install && rm -rf /tmp/*

# копируем все файлы из текущей директории в рабочую кроме файлов из .dockerignore
COPY . .

# выполняем команду сброки
RUN npm run build

# Переходим на непривилегированного пользователя
USER appuser

# порт который использует приложение для входящих подключений
EXPOSE 3000

# устанавливаем команду, которая будет выполнятся при запуске контейнера
CMD ["sh", "-c", "npm run migration:run && npm run start:prod"]
