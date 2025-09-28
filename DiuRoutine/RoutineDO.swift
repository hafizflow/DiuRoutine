import SwiftData

@Model
class RoutineDO {
    @Attribute(.unique) var id: Int
    var day: String?
    var startTime: String?
    var endTime: String?
    var section: String?
    var room: String?
    var initial: String?
    var courseInfo: CourseInfoDO?
    var teacherInfo: TeacherInfoDO?
    
    init(
        id: Int,
        day: String?,
        startTime: String?,
        endTime: String?,
        section: String?,
        room: String?,
        initial: String?,
        courseInfo: CourseInfoDO?,
        teacherInfo: TeacherInfoDO?
    ) {
        self.id = id
        self.day = day
        self.startTime = startTime
        self.endTime = endTime
        self.section = section
        self.room = room
        self.initial = initial
        self.courseInfo = courseInfo
        self.teacherInfo = teacherInfo
    }
    
    convenience init(dto: RoutineDTO) {
        self.init(
            id: dto.id,
            day: dto.day,
            startTime: dto.startTime,
            endTime: dto.endTime,
            section: dto.section,
            room: dto.room,
            initial: dto.initial,
            courseInfo: dto.courseInfo.map { CourseInfoDO(dto: $0) },
            teacherInfo: dto.teacherInfo.map { TeacherInfoDO(dto: $0) }
        )
    }
}

@Model
class CourseInfoDO {
    var code: String?
    var title: String?
    var credit: Double?
    
    init(code: String?, title: String?, credit: Double?) {
        self.code = code
        self.title = title
        self.credit = credit
    }
    
    convenience init(dto: CourseInfoDTO) {
        self.init(code: dto.code, title: dto.title, credit: dto.credit)
    }
}

@Model
class TeacherInfoDO {
    var initial: String?
    var name: String?
    var designation: String?
    var cell: String?
    var email: String?
    var imageUrl: String?
    
    init(initial: String?, name: String?, designation: String?, cell: String?, email: String?, imageUrl: String?) {
        self.initial = initial
        self.name = name
        self.designation = designation
        self.cell = cell
        self.email = email
        self.imageUrl = imageUrl
    }
    
    convenience init(dto: TeacherInfoDTO) {
        self.init(
            initial: dto.initial,
            name: dto.name,
            designation: dto.designation,
            cell: dto.cell,
            email: dto.email,
            imageUrl: dto.imageUrl
        )
    }
}
