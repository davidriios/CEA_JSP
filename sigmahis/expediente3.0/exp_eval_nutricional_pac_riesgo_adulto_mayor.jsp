<table cellspacing="0" class="table table-small-font table-bordered table-striped">

<tr>
    <td class="2">
        <button type="button" id="btn_ant_alergicos2" class="btn btn-inverse btn-sm">
                <i class="fa fa-eye fa-lg"></i> Antecendes Al&eacute;gicos
            </button>
            <button type="button" id="btn_eval_3" class="btn btn-inverse btn-sm">
                <i class="fa fa-eye fa-lg"></i> Evaluaci&oacute;n I
            </button>
            
            <button type="button" id="btn_inhaloterapia" class="btn btn-inverse btn-sm">
               <i class="fa fa-eye fa-lg"></i> O/M Medicamentos
            </button>
            <button type="button" id="btn_laboratorios" class="btn btn-inverse btn-sm">
               <i class="fa fa-eye fa-lg"></i> O/M Laboratorios
            </button>
    </td>
<tr>

<tr class="bg-headtabla">
    <td>CRIBAJE</td>
    <td>EVALUACION</td>
</tr>
<tr>
    <td width="50%" class="controls form-inline" style="vertical-align:top !important;">
        <b>1.&nbsp;Ha perdido el apetito? Ha comido menos por falta de apetito, problemas digestivos, dificultad para masticar o deglutir en los &uacute;ltimos 3 meses?</b>
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <%=fb.textBox("resulta_1", prop.getProperty("resulta_1"),false,false,viewMode,60,"form-control input-sm cribaje","width:50px",null)%>
        <br>
        <label class="pointer">Anorexia grave&nbsp;<%=fb.radio("pregunta_1","0",(prop.getProperty("pregunta_1")!=null && prop.getProperty("pregunta_1").equalsIgnoreCase("0")),viewMode,false,"pregunta_1", null,null,null," data-index=1")%></label>
        &nbsp;&nbsp;&nbsp;
        <label class="pointer">Anorexia moderada&nbsp;<%=fb.radio("pregunta_1","1",(prop.getProperty("pregunta_1")!=null && prop.getProperty("pregunta_1").equalsIgnoreCase("1")),viewMode,false,"pregunta_1", null,null,null," data-index=1")%></label>
        &nbsp;&nbsp;&nbsp;
        <label class="pointer">Sin anorexia&nbsp;<%=fb.radio("pregunta_1","2",(prop.getProperty("pregunta_1")!=null && prop.getProperty("pregunta_1").equalsIgnoreCase("2")),viewMode,false,"pregunta_1", null,null,null," data-index=1")%></label>
    </td>
    <td class="controls form-inline" style="vertical-align:top !important;">
        <b>12.&nbsp;Consume el paciente</b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <%=fb.textBox("resulta_12", prop.getProperty("resulta_12"),false,false,viewMode,60,"form-control input-sm","width:50px",null)%>
        <br>
        <ul>
            <li>
                Productos l&aacute;cteos por lo menos una vez al d&iacute;a?
                &nbsp;&nbsp;&nbsp;
                <label class="pointer">SI&nbsp;<%=fb.radio("pregunta_12_1","Y",(prop.getProperty("pregunta_12_1")!=null && prop.getProperty("pregunta_12_1").equalsIgnoreCase("Y")),viewMode,false,"pregunta_12", null,"")%></label>
                &nbsp;&nbsp;&nbsp;
                <label class="pointer">NO&nbsp;<%=fb.radio("pregunta_12_1","N",(prop.getProperty("pregunta_12_1")!=null && prop.getProperty("pregunta_12_1").equalsIgnoreCase("N")),viewMode,false,"pregunta_12", null,"")%></label>
            </li>
            <li>
                Huevos o legumbres 1 o 2 veces por semana?
                &nbsp;&nbsp;&nbsp;
                <label class="pointer">SI&nbsp;<%=fb.radio("pregunta_12_2","Y",(prop.getProperty("pregunta_12_2")!=null && prop.getProperty("pregunta_12_2").equalsIgnoreCase("Y")),viewMode,false,"pregunta_12", null,"")%></label>
                &nbsp;&nbsp;&nbsp;
                <label class="pointer">NO&nbsp;<%=fb.radio("pregunta_12_2","N",(prop.getProperty("pregunta_12_2")!=null && prop.getProperty("pregunta_12_2").equalsIgnoreCase("N")),viewMode,false,"pregunta_12", null,"")%></label>
            </li>
            <li>
                Carne, pescado o aves, diariamente?
                &nbsp;&nbsp;&nbsp;
                <label class="pointer">SI&nbsp;<%=fb.radio("pregunta_12_3","Y",(prop.getProperty("pregunta_12_3")!=null && prop.getProperty("pregunta_12_3").equalsIgnoreCase("Y")),viewMode,false,"pregunta_12", null,"")%></label>
                &nbsp;&nbsp;&nbsp;
                <label class="pointer">NO&nbsp;<%=fb.radio("pregunta_12_3","N",(prop.getProperty("pregunta_12_3")!=null && prop.getProperty("pregunta_12_3").equalsIgnoreCase("N")),viewMode,false,"pregunta_12", null,"")%></label>
            </li>
        </ul>
    </td>
</tr>

<tr>
    <td width="50%" class="controls form-inline" style="vertical-align:top !important;">
        <b>2.&nbsp;Perdidad reciente de peso (<3 meses)?</b>
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <%=fb.textBox("resulta_2", prop.getProperty("resulta_2"),false,false,viewMode,60,"form-control input-sm cribaje","width:50px",null)%>
        <br>
        <label class="pointer">p&eacute;dida de peso > kg (6.6 lb)&nbsp;<%=fb.radio("pregunta_2","0",(prop.getProperty("pregunta_2")!=null && prop.getProperty("pregunta_2").equalsIgnoreCase("0")),viewMode,false,"pregunta_2", null,null,null," data-index=2")%></label>
        &nbsp;&nbsp;&nbsp;
        <label class="pointer">no lo sabe&nbsp;<%=fb.radio("pregunta_2","1",(prop.getProperty("pregunta_2")!=null && prop.getProperty("pregunta_2").equalsIgnoreCase("1")),viewMode,false,"pregunta_2", null,null,null," data-index=2")%></label>
        &nbsp;&nbsp;&nbsp;
        <label class="pointer">p&eacute;dida de peso entre 1 a 3 kg (2.2 a 6.6 lb)&nbsp;<%=fb.radio("pregunta_2","2",(prop.getProperty("pregunta_2")!=null && prop.getProperty("pregunta_2").equalsIgnoreCase("2")),viewMode,false,"pregunta_2", null,null,null," data-index=2")%></label>
        &nbsp;&nbsp;&nbsp;
        <label class="pointer">no ha habido p&eacute;dida de peso&nbsp;<%=fb.radio("pregunta_2","3",(prop.getProperty("pregunta_2")!=null && prop.getProperty("pregunta_2").equalsIgnoreCase("3")),viewMode,false,"pregunta_2", null,null,null," data-index=2")%></label>
    </td>
    
    <td class="controls form-inline" style="vertical-align: top !important;">
        <b>13.&nbsp;Cuantos vasos de agua u otros l&aacute;quidos toma al d&iacute;a (agua, zumo, caf&eacute;, t&eacute;, leche, vino, cerveza...)</b>
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <%=fb.textBox("resulta_13", prop.getProperty("resulta_13"),false,false,viewMode,60,"form-control input-sm","width:50px",null)%>
        <br>
        <label class="pointer">menos de 3 vasos&nbsp;<%=fb.radio("pregunta_13","0",(prop.getProperty("pregunta_13")!=null && prop.getProperty("pregunta_13").equalsIgnoreCase("0")),viewMode,false,"pregunta_13", null,null,null," data-index=13")%></label>
        &nbsp;&nbsp;&nbsp;
        <label class="pointer">de 3 a 5 vasos&nbsp;<%=fb.radio("pregunta_13","0.5",(prop.getProperty("pregunta_13")!=null && prop.getProperty("pregunta_13").equalsIgnoreCase("0.5")),viewMode,false,"pregunta_13", null,null,null," data-index=13")%></label>
        &nbsp;&nbsp;&nbsp;
        <label class="pointer">m&aacute;s de 5&nbsp;<%=fb.radio("pregunta_13","1.0",(prop.getProperty("pregunta_13")!=null && prop.getProperty("pregunta_13").equalsIgnoreCase("1.0")),viewMode,false,"pregunta_13", null,null,null," data-index=13")%></label>
    </td>
</tr>

<tr>
    <td width="50%" class="controls form-inline" style="vertical-align:top !important;">
        <b>3.&nbsp;Movilidad</b>
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <%=fb.textBox("resulta_3", prop.getProperty("resulta_3"),false,false,viewMode,60,"form-control input-sm cribaje","width:50px",null)%>
        &nbsp;&nbsp;&nbsp;
        <label class="pointer">de la cama al sill&oacute;n&nbsp;<%=fb.radio("pregunta_3","0",(prop.getProperty("pregunta_3")!=null && prop.getProperty("pregunta_3").equalsIgnoreCase("0")),viewMode,false,"pregunta_3", null,null,null," data-index=3")%></label>
        &nbsp;&nbsp;&nbsp;
        <label class="pointer">autonom&iacute;a en el interior&nbsp;<%=fb.radio("pregunta_3","1",(prop.getProperty("pregunta_3")!=null && prop.getProperty("pregunta_3").equalsIgnoreCase("1")),viewMode,false,"pregunta_3", null,null,null," data-index=3")%></label>
        &nbsp;&nbsp;&nbsp;
        <label class="pointer">sale del domicilio&nbsp;<%=fb.radio("pregunta_3","2",(prop.getProperty("pregunta_3")!=null && prop.getProperty("pregunta_3").equalsIgnoreCase("2")),viewMode,false,"pregunta_3", null,null,null," data-index=3")%></label>
    </td>
    <td class="controls form-inline" style="vertical-align: top !important;">
        <b>14.&nbsp;Forma de alimentarse</b>
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <%=fb.textBox("resulta_14", prop.getProperty("resulta_14"),false,false,viewMode,60,"form-control input-sm","width:50px",null)%>
        &nbsp;&nbsp;&nbsp;
        <label class="pointer">necesita ayuda&nbsp;<%=fb.radio("pregunta_14","0",(prop.getProperty("pregunta_14")!=null && prop.getProperty("pregunta_14").equalsIgnoreCase("0")),viewMode,false,"pregunta_14", null,null,null," data-index=14")%></label>
        &nbsp;&nbsp;&nbsp;
        <label class="pointer">se alimenta solo con dificultad&nbsp;<%=fb.radio("pregunta_14","1",(prop.getProperty("pregunta_14")!=null && prop.getProperty("pregunta_14").equalsIgnoreCase("1")),viewMode,false,"pregunta_14", null,null,null," data-index=14")%></label>
        &nbsp;&nbsp;&nbsp;
        <label class="pointer">se alimenta solo sin dificultad&nbsp;<%=fb.radio("pregunta_14","2",(prop.getProperty("pregunta_14")!=null && prop.getProperty("pregunta_14").equalsIgnoreCase("2")),viewMode,false,"pregunta_14", null,null,null," data-index=14")%></label>
    </td>    
</tr>

<tr>
    <td width="50%" class="controls form-inline" style="vertical-align:top !important;">
        <b>4.&nbsp;Ha tenido una enfermedad aguda o situaci&oacute;n de estr&eacute;s psicol&oacute;gico en los &uacute;ltimos 3 meses?</b>
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <%=fb.textBox("resulta_4", prop.getProperty("resulta_4"),false,false,viewMode,60,"form-control input-sm cribaje","width:50px",null)%>
        &nbsp;&nbsp;&nbsp;
        <label class="pointer">SI&nbsp;<%=fb.radio("pregunta_4","0",(prop.getProperty("pregunta_4")!=null && prop.getProperty("pregunta_4").equalsIgnoreCase("0")),viewMode,false,"pregunta_4", null,null,null," data-index=4")%></label>
        &nbsp;&nbsp;&nbsp;
        <label class="pointer">NO&nbsp;<%=fb.radio("pregunta_4","1",(prop.getProperty("pregunta_4")!=null && prop.getProperty("pregunta_4").equalsIgnoreCase("1")),viewMode,false,"pregunta_4", null,null,null," data-index=4")%></label>
    </td>
    <td class="controls form-inline" style="vertical-align:top !important;">
        <b>15.&nbsp;Se considera el paciente que est&aacute; bien nutrido?</b>
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <%=fb.textBox("resulta_15", prop.getProperty("resulta_15"),false,false,viewMode,60,"form-control input-sm","width:50px",null)%>
        &nbsp;&nbsp;&nbsp;
        <label class="pointer">malnutrici&oacute;n grave&nbsp;<%=fb.radio("pregunta_15","0",(prop.getProperty("pregunta_15")!=null && prop.getProperty("pregunta_15").equalsIgnoreCase("0")),viewMode,false,"pregunta_15", null,null,null," data-index=15")%></label>
        &nbsp;&nbsp;&nbsp;
        <label class="pointer">no lo sabe o malnutrici&oacute;n moderada&nbsp;<%=fb.radio("pregunta_15","1",(prop.getProperty("pregunta_15")!=null && prop.getProperty("pregunta_15").equalsIgnoreCase("1")),viewMode,false,"pregunta_15", null,null,null," data-index=15")%></label>
        &nbsp;&nbsp;&nbsp;
        <label class="pointer">sin problemas de nutrici&oacute;n&nbsp;<%=fb.radio("pregunta_15","2",(prop.getProperty("pregunta_15")!=null && prop.getProperty("pregunta_15").equalsIgnoreCase("2")),viewMode,false,"pregunta_15", null,null,null," data-index=15")%></label>
        <br>
    </td>    
</tr>

<tr>
    <td width="50%" class="controls form-inline" style="vertical-align:top !important;">
        <b>5.&nbsp;Problemas Neurol&oacute;gicos</b>
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <%=fb.textBox("resulta_5", prop.getProperty("resulta_5"),false,false,viewMode,60,"form-control input-sm cribaje","width:50px",null)%>
        &nbsp;&nbsp;&nbsp;
        <label class="pointer">demencia o depresi&oacute;n grave&nbsp;<%=fb.radio("pregunta_5","0",(prop.getProperty("pregunta_5")!=null && prop.getProperty("pregunta_5").equalsIgnoreCase("0")),viewMode,false,"pregunta_5", null,null,null," data-index=5")%></label>
        &nbsp;&nbsp;&nbsp;
        <label class="pointer">demencia o depresi&oacute;n moderada&nbsp;<%=fb.radio("pregunta_5","1",(prop.getProperty("pregunta_5")!=null && prop.getProperty("pregunta_5").equalsIgnoreCase("1")),viewMode,false,"pregunta_5", null,null,null," data-index=5")%></label>
        &nbsp;&nbsp;&nbsp;
        <label class="pointer">sin problemas neurol&oacute;gicos&nbsp;<%=fb.radio("pregunta_5","2",(prop.getProperty("pregunta_5")!=null && prop.getProperty("pregunta_5").equalsIgnoreCase("2")),viewMode,false,"pregunta_5", null,null,null," data-index=5")%></label>
    </td>
    <td class="controls form-inline" style="vertical-align:top !important;">
        <b>16.&nbsp;En comparaci&oacute;n con otras personas de su edad, como encuentra el paciente su estado de salud?</b>
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <%=fb.textBox("resulta_16", prop.getProperty("resulta_16"),false,false,viewMode,60,"form-control input-sm","width:50px",null)%>
        <br>
        <label class="pointer">peor&nbsp;<%=fb.radio("pregunta_16","0",(prop.getProperty("pregunta_16")!=null && prop.getProperty("pregunta_16").equalsIgnoreCase("0")),viewMode,false,"pregunta_16", null,null,null," data-index=16")%></label>
        &nbsp;&nbsp;&nbsp;
        <label class="pointer">no lo sabe&nbsp;<%=fb.radio("pregunta_16","0.5",(prop.getProperty("pregunta_16")!=null && prop.getProperty("pregunta_16").equalsIgnoreCase("0.5")),viewMode,false,"pregunta_16", null,null,null," data-index=16")%></label>
        &nbsp;&nbsp;&nbsp;
        <label class="pointer">igual&nbsp;<%=fb.radio("pregunta_16","1",(prop.getProperty("pregunta_16")!=null && prop.getProperty("pregunta_16").equalsIgnoreCase("1")),viewMode,false,"pregunta_16", null,null,null," data-index=16")%></label>
        &nbsp;&nbsp;&nbsp;
        <label class="pointer">mejor&nbsp;<%=fb.radio("pregunta_16","2",(prop.getProperty("pregunta_16")!=null && prop.getProperty("pregunta_16").equalsIgnoreCase("2")),viewMode,false,"pregunta_16", null,null,null," data-index=16")%></label>
    </td>
</tr>

<tr>
    <td width="50%" class="controls form-inline" style="vertical-align:top !important;">
        <b>6.&nbsp;&Iacute;ndice de Masa Corporal</b>
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <%=fb.textBox("resulta_6", prop.getProperty("resulta_6"),false,false,viewMode,60,"form-control input-sm cribaje","width:50px",null)%>
        &nbsp;&nbsp;&nbsp;
        <label class="pointer">< 19&nbsp;<%=fb.radio("pregunta_6","0",(prop.getProperty("pregunta_6")!=null && prop.getProperty("pregunta_6").equalsIgnoreCase("0")),viewMode,false,"pregunta_6", null,null,null," data-index=6")%></label>
        &nbsp;&nbsp;&nbsp;
        <label class="pointer">19 <= IMC < 21&nbsp;<%=fb.radio("pregunta_6","1",(prop.getProperty("pregunta_6")!=null && prop.getProperty("pregunta_6").equalsIgnoreCase("1")),viewMode,false,"pregunta_6", null,null,null," data-index=6")%></label> 
        &nbsp;&nbsp;&nbsp;
        <label class="pointer">21 <= IMC < 23&nbsp;<%=fb.radio("pregunta_6","2",(prop.getProperty("pregunta_6")!=null && prop.getProperty("pregunta_6").equalsIgnoreCase("2")),viewMode,false,"pregunta_6", null,null,null," data-index=6")%></label>  
        &nbsp;&nbsp;&nbsp;
        <label class="pointer">>= 23&nbsp;<%=fb.radio("pregunta_6","3",(prop.getProperty("pregunta_6")!=null && prop.getProperty("pregunta_6").equalsIgnoreCase("3")),viewMode,false,"pregunta_6", null,null,null," data-index=6")%></label>
        <br>
        <br>
        <b>
        Evaluaci&oacute;n de Cribaje<br>Total de Puntos Obtenidos:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <%=fb.textBox("total_cribaje", prop.getProperty("total_cribaje"),false,false,true,60,"form-control input-sm","width:80px",null)%>
        &nbsp;&nbsp;&nbsp;
        <%//=fb.textarea("total_cribaje_dsp", prop.getProperty("total_cribaje_dsp"),false,false,true,60,"form-control input-sm","width:300px",null)%>
        <%=fb.textarea("total_cribaje_dsp",prop.getProperty("total_cribaje_dsp"),false,false,true,35,2,0,"form-control input-sm","",null)%>
        </b>
    </td>
    <td width="50%" class="controls form-inline" style="vertical-align:top !important;">
        <b>17.&nbsp;Circunferencia braquial (CB en cm)</b>
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <%=fb.textBox("resulta_17", prop.getProperty("resulta_17"),false,false,viewMode,60,"form-control input-sm","width:50px",null)%>
        &nbsp;&nbsp;&nbsp;
        <label class="pointer">CB < 21&nbsp;<%=fb.radio("pregunta_17","0.0",(prop.getProperty("pregunta_17")!=null && prop.getProperty("pregunta_17").equalsIgnoreCase("0.0")),viewMode,false,"pregunta_17", null,null,null," data-index=17")%></label>  
        &nbsp;&nbsp;&nbsp;
        <label class="pointer">21 <= CB <= 22&nbsp;<%=fb.radio("pregunta_17","0.5",(prop.getProperty("pregunta_17")!=null && prop.getProperty("pregunta_17").equalsIgnoreCase("0.5")),viewMode,false,"pregunta_17", null,null,null," data-index=17")%></label>   
        &nbsp;&nbsp;&nbsp;
        <label class="pointer">CB > 22&nbsp;<%=fb.radio("pregunta_17","1",(prop.getProperty("pregunta_17")!=null && prop.getProperty("pregunta_17").equalsIgnoreCase("1")),viewMode,false,"pregunta_17", null,null,null," data-index=17")%></label>  
    </td>
</tr>

<tr>
    <td colspan="2" class="controls form-inline bg-headtabla" style="vertical-align:top !important;">
    EVALUACION
    </td>
</tr>

<tr>
    <td width="50%" class="controls form-inline" style="vertical-align:top !important;">
        <b>7.&nbsp;El paciente vive independiente en su domicilio?</b>
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <%=fb.textBox("resulta_7", prop.getProperty("resulta_7"),false,false,viewMode,60,"form-control input-sm","width:50px",null)%>
        &nbsp;&nbsp;&nbsp;
        <label class="pointer">SI&nbsp;<%=fb.radio("pregunta_7","1",(prop.getProperty("pregunta_7")!=null && prop.getProperty("pregunta_7").equalsIgnoreCase("1")),viewMode,false,"pregunta_7", null,null,null," data-index=7")%></label>
        &nbsp;&nbsp;&nbsp;
        <label class="pointer">NO&nbsp;<%=fb.radio("pregunta_7","0",(prop.getProperty("pregunta_7")!=null && prop.getProperty("pregunta_7").equalsIgnoreCase("0")),viewMode,false,"pregunta_7", null,null,null," data-index=7")%></label>
        &nbsp;&nbsp;&nbsp;
    </td>
    <td width="50%" class="controls form-inline" style="vertical-align:top !important;">
        <b>18.&nbsp;Circunferencia de la pantorrilla (CP en cm)</b>
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <%=fb.textBox("resulta_18", prop.getProperty("resulta_18"),false,false,viewMode,60,"form-control input-sm","width:50px",null)%>
        &nbsp;&nbsp;&nbsp;
        <label class="pointer">CP < 31&nbsp;<%=fb.radio("pregunta_18","0",(prop.getProperty("pregunta_18")!=null && prop.getProperty("pregunta_18").equalsIgnoreCase("0")),viewMode,false,"pregunta_18", null,null,null," data-index=18")%></label>
        &nbsp;&nbsp;&nbsp;
        <label class="pointer">CP >= 31&nbsp;<%=fb.radio("pregunta_18","1",(prop.getProperty("pregunta_18")!=null && prop.getProperty("pregunta_18").equalsIgnoreCase("1")),viewMode,false,"pregunta_18", null,null,null," data-index=18")%></label>
        &nbsp;&nbsp;&nbsp;
    </td>    
</tr>

<tr>
    <td width="50%" class="controls form-inline" style="vertical-align:top !important;">
        <b>8.&nbsp;Toma m&aacute;s de 3 medicamentos al d&iacute;a?</b>
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <%=fb.textBox("resulta_8", prop.getProperty("resulta_8"),false,false,viewMode,60,"form-control input-sm","width:50px",null)%>
        &nbsp;&nbsp;&nbsp;
        <label class="pointer">SI&nbsp;<%=fb.radio("pregunta_8","0",(prop.getProperty("pregunta_8")!=null && prop.getProperty("pregunta_8").equalsIgnoreCase("0")),viewMode,false,"pregunta_8", null,null,null," data-index=8")%></label>
        &nbsp;&nbsp;&nbsp;
        <label class="pointer">NO&nbsp;<%=fb.radio("pregunta_8","1",(prop.getProperty("pregunta_8")!=null && prop.getProperty("pregunta_8").equalsIgnoreCase("1")),viewMode,false,"pregunta_8", null,null,null," data-index=8")%></label>
    </td>
    
    <td class="controls form-inline" style="vertical-align:top !important;">
        <b>
        Evaluaci&oacute;n:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <%=fb.textBox("total_eval", prop.getProperty("total_eval"),false,false,true,60,"form-control input-sm","width:80px",null)%>
        <br>Evaluaci&oacute;n Global:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <%=fb.textBox("total_global", prop.getProperty("total_global"),false,false,true,60,"form-control input-sm","width:80px",null)%>
        <%=fb.textBox("total_global_dsp", prop.getProperty("total_global_dsp"),false,false,true,60,"form-control input-sm","width:300px",null)%>
        &nbsp;&nbsp;&nbsp;
        </b>
    </td>
</tr>

<tr>
    <td width="50%" class="controls form-inline" style="vertical-align:top !important;">
        <b>9.&nbsp;Ulceras o lesiones cut&aacute;neas?</b>
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <%=fb.textBox("resulta_9", prop.getProperty("resulta_9"),false,false,viewMode,60,"form-control input-sm","width:50px",null)%>
        &nbsp;&nbsp;&nbsp;
        <label class="pointer">SI&nbsp;<%=fb.radio("pregunta_9","0",(prop.getProperty("pregunta_9")!=null && prop.getProperty("pregunta_9").equalsIgnoreCase("0")),viewMode,false,"pregunta_9", null,null,null," data-index=9")%></label>
        &nbsp;&nbsp;&nbsp;
        <label class="pointer">NO&nbsp;<%=fb.radio("pregunta_9","1",(prop.getProperty("pregunta_9")!=null && prop.getProperty("pregunta_9").equalsIgnoreCase("1")),viewMode,false,"pregunta_9", null,null,null," data-index=9")%></label>
    </td>
    <td></td>
</tr>

<tr>
    <td width="50%" class="controls form-inline" style="vertical-align:top !important;">
        <b>10.&nbsp;Cuantas comidas completas toma al d&iacute;a?</b>
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <%=fb.textBox("resulta_10", prop.getProperty("resulta_10"),false,false,viewMode,60,"form-control input-sm","width:50px",null)%>
        &nbsp;&nbsp;&nbsp;
        <label class="pointer">1 comida&nbsp;<%=fb.radio("pregunta_10","0",(prop.getProperty("pregunta_10")!=null && prop.getProperty("pregunta_10").equalsIgnoreCase("0")),viewMode,false,"pregunta_10", null,null,null," data-index=10")%></label>
        &nbsp;&nbsp;&nbsp;
        <label class="pointer">2 comidas&nbsp;<%=fb.radio("pregunta_10","1",(prop.getProperty("pregunta_10")!=null && prop.getProperty("pregunta_10").equalsIgnoreCase("1")),viewMode,false,"pregunta_10", null,null,null," data-index=10")%></label>
        &nbsp;&nbsp;&nbsp;
        <label class="pointer">3 comidas&nbsp;<%=fb.radio("pregunta_10","2",(prop.getProperty("pregunta_10")!=null && prop.getProperty("pregunta_10").equalsIgnoreCase("2")),viewMode,false,"pregunta_10", null,null,null," data-index=10")%></label>
    </td>
    <td></td>
</tr>

<tr>
    <td width="50%" class="controls form-inline" style="vertical-align:top !important;">
        <b>11.&nbsp;Consume frutas o verduras al menos 2 veces por d&iacute;a?</b>
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <%=fb.textBox("resulta_11", prop.getProperty("resulta_11"),false,false,viewMode,60,"form-control input-sm","width:50px",null)%>
        &nbsp;&nbsp;&nbsp;
        <label class="pointer">SI&nbsp;<%=fb.radio("pregunta_11","1",(prop.getProperty("pregunta_11")!=null && prop.getProperty("pregunta_11").equalsIgnoreCase("1")),viewMode,false,"pregunta_11", null,null,null," data-index=11")%></label>
        &nbsp;&nbsp;&nbsp;
        <label class="pointer">No&nbsp;<%=fb.radio("pregunta_11","0",(prop.getProperty("pregunta_11")!=null && prop.getProperty("pregunta_11").equalsIgnoreCase("0")),viewMode,false,"pregunta_11", null,null,null," data-index=11")%></label>
    </td>
    <td></td>
</tr>    



</table>
