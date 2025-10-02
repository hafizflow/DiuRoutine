 


struct RoutineDTOResponse: Decodable {
    let data: [RoutineDTO]
}

struct RoutineDTO: Decodable {
    let id: Int
    let day: String?
    let startTime: String?
    let endTime: String?
    let section: String?
    let room: String?
    let initial: String?
    let courseInfo: CourseInfoDTO?
    let teacherInfo: TeacherInfoDTO?
}

struct CourseInfoDTO: Decodable {
    let code: String?
    let title: String?
    let credit: Double?
}

struct TeacherInfoDTO: Decodable {
    let initial: String?
    let name: String?
    let designation: String?
    let cell: String?
    let email: String?
    let imageUrl: String?
    let teacherRoom: String?
}



struct VersionResponse: Decodable {
    let data: Version
}

struct Version: Decodable {
    let version: String
    let inMaintenance: Bool
}
