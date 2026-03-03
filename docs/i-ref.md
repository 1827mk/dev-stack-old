  /dev-stack:agents '/Users/tanaphat.oiu/.claude/dev-stack-marketplace' ทำความเข้าใจใหม่นะครับ ฉันต้องการทำ agents ที่เรียกใช้งาน tools ต่างๆ ของฉันตามใน list  
  '/Users/tanaphat.oiu/.claude/dev-stack-marketplace/docs/tools_name.md' ตัว agent ทำหน้าที่ เป็นตัววิเคราะห์ และบริหารจัดกา sub agents อื่นๆ                       
  ตามงานที่ได้รับมอบผมายจากผู้ใช้ แต่ละงานอาจจะใช้ sub agent ย่อยๆ ไม่คงที่ ไม่ได้ fic ว่าทุกงานต้องมี workflow เดียวกัน เช่นถ้าเรียก agent หลัก /dev-stack:agents <task         
  request> ตัว agents หลักกจะวิเคราะห์เลือกใช้ sub agents ต่างๆได้มากกว่า 1 agent , แต่ถ้าเรียก sub agents เช่น /dev-stack:bug ตัว sub agent ก็ทำหน้าที่จัดเซต ได้เฉพราะเรื่องที่เกี่ยว fix bug    
  ,ถ้าเรียก sub agent เช่น /dev-stack:git ก็จะได้ได้แค่ scope ของ git เท่านั้น ,    
  ตัวอย่าง 
  /dev-stack:agents  ช่วยตรวจสอบบัคของ xxx/xxx .xxx  ตัว agent ก็จะเลือก sub agent : dev,qa ,,.... และอื่นๆ 
  /dev-stack:bug ช่วยตรวจสอบบัคของ xxx/xxx .xxx  ตัว agent ก็จะเลือก sub agent :dev ,qa เท่านั้น เพราะเกี่ยวข้องแค่นี้ (ยกตัวอย่างนะครับ)
  โดยการเรียก agent , subagent ตัว claude code จะเปิดเป็น team agent และมี sub agent ช่วยกันทำงานที่ได้รับมอบหมาย 
  แบบนี้คือที่คาดหงวัง คุณคิดว่าเป็นอย่างไรบ้างครับ ต้องปรับปรุงอะไรไหม ยังไม่ต้องแก้ไข code เพียงแค่คุนกันก่อน
  
  
   ไม่ต้องใช้ tools ทั้งหมาตามใน list ก็ได้ครับ ให้เลือกตามความสำคัญคือ mcp server,plugins,skill, และ built in เป็นลำดับสุดท้าย
   ลำดับความสำคัญของการสร้าง agent ตัวนี้ คือการเลือก tools ตาม คุณภาพของงาน > เวลาการทำงาน เสมอ 
   
   
   ให้ใช้ความสำคัญในการเลือก tools : mcp server >plugins > skills > built in tools 
Domain Driven Design (DDD)
Test Driven Development (TDD)
Behavior Driven Development (BDD)
และมุ่งเน้นไปที่ Spec-Driven Development (SDD) เพื่อที่ บาง task ไม่สามารถจบได้ในวันเดียว , หรือมีการสลับไปทำอย่างอื่น , หรือ switch ไปทำอย่างอื่นบน branch อื่น เลือกใช้ได้เลยทั้ง superpower  หรือ spec-kit (https://github.com/github/spec-kit  ฉันติดตั้งไว้แล้ว) 
