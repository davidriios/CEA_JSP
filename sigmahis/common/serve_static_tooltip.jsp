<% response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); %>
<%//@ page trimDirectiveWhitespaces="true" %>
<%@page contentType="text/html" %>
<%
String contentFor = request.getParameter("contentFor")==null?"":request.getParameter("contentFor");
if (contentFor.trim().equals("ADM_CONF")){
%>
"content-1":"<div class='Text10Bold'>Condiciones del Paciente que pudieran considerarse como riesgo de ca�da.<ul><li>Embarazada</li><li>Paciente Geri�trico</li><li>Paciente en silla de ruedas</li><li>Paciente requiere asistencia para movilizarse</li><li>Paciente con bast�n /andadera</li><li>Paciente con muletas</li><li>Paciente invidente</li><li>Otros</li></ul></div>"
<%}%>