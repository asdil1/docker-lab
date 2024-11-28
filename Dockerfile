FROM node:18-alpine AS builder

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

CMD ["sh", "-c", "npm run migration:run"]

FROM node:18-alpine

# Добавляем непривилегированного пользователя
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /usr/src/app

# Копируем собранные файлы из builder
COPY --from=builder /usr/src/app/dist ./dist
COPY --from=builder /usr/src/app/node_modules ./node_modules
COPY --from=builder /usr/src/app/package*.json ./

# Переходим на непривилегированного пользователя
USER appuser

# порт который использует приложение для входящих подключений
EXPOSE 3000

# Запуск приложения
CMD ["sh", "-c", "npm run start:prod"]
