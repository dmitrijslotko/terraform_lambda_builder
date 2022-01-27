FROM public.ecr.aws/lambda/nodejs:14

COPY code/  ${LAMBDA_TASK_ROOT}
RUN npm install
CMD [ "index.handler" ]  
