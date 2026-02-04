//
//  CookingCompleteReviewModalView.swift
//  mohaemukzip
//
//  Created by 고석현 on 1/29/26.
//

// MARK: - 요리 완료 확인 모달 (UI 전용)

/// 별점 1점 이상 선택 시에만 제출 버튼 활성화
/// 제출 시(onSubmit) 상위 뷰에서 요리 완료 API 호출 연결
/// 제출 중(isSubmitting)에는 닫기/취소 동작 비활성화
import SwiftUI

struct CookingCompleteReviewModalView: View {

    // MARK: - Properties

    /// 모달 표시 여부
    @Binding var isPresented: Bool

    /// 선택된 별점(1~5)
    @Binding var selectedRating: Int

    /// 제출 액션
    /// - Parameter rating: 선택된 별점(1~5)
    /// - Note: 상위 뷰에서 요리 완료 API 호출 트리거로 사용
    let onSubmit: (Int) -> Void

    /// 제출 중 여부
    /// - Note: 제출 중에는 배경 탭/취소로 닫히지 않도록 제어
    let isSubmitting: Bool

    // MARK: - Init

    init(
        isPresented: Binding<Bool>,
        selectedRating: Binding<Int>,
        isSubmitting: Bool = false,
        onSubmit: @escaping (Int) -> Void
    ) {
        self._isPresented = isPresented
        self._selectedRating = selectedRating
        self.isSubmitting = isSubmitting
        self.onSubmit = onSubmit
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            /// 배경 딤 처리
            Color.black.opacity(0.45)
                .ignoresSafeArea()
                .onTapGesture {
                    /// 제출 중 실수 닫힘 방지
                    guard !isSubmitting else { return }
                    isPresented = false
                }

            /// 모달 카드
            VStack(spacing: 0) {
                VStack(spacing: 14) {
                    Text("요리 완료")
                        .font(.custom("Pretendard-SemiBold", size: 20))
                        .foregroundStyle(Color("grey900"))

                    /// 캐릭터 이미지 (Asset: "review")
                    Image("review")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 82, height: 82)
                        .clipShape(Circle())

                    Text(
                        "요리는 성공적이었나요?\n"
                        + "방금 한 요리의 난이도를 평가하고\n"
                        + "루틴에 기록해보세요."
                    )
                    .font(.custom("Pretendard-Regular", size: 16))
                    .foregroundStyle(Color("grey900"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.top, 6)

                    // MARK: 별점 선택
                    /// 별점 미선택(0점) 상태에서는 제출 불가
                    StarRatingPicker(
                        selectedRating: $selectedRating,
                        maxRating: 5
                    )
                    .padding(.top, 10)
                }
                .padding(.top, 22)
                .padding(.horizontal, 20)

                /// 하단 버튼 영역
                HStack(spacing: 12) {
                    Button {
                        /// 취소: 저장 없이 닫기
                        guard !isSubmitting else { return }
                        isPresented = false
                    } label: {
                        Text("취소")
                            .font(.custom("Pretendard-Medium", size: 16))
                            .foregroundStyle(isSubmitting ? Color("grey400") : Color("grey900"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color("grey200"), lineWidth: 1)
                            )
                    }

                    Button {
                        /// 제출: 별점 선택 시에만 실행
                        guard selectedRating >= 1 else { return }
                        guard !isSubmitting else { return }
                        onSubmit(selectedRating)
                    } label: {
                        Text(isSubmitting ? "처리 중" : "요리완료")
                            .font(.custom("Pretendard-Medium", size: 16))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(
                                        (selectedRating >= 1 && !isSubmitting)
                                        ? Color.orange
                                        : Color(.systemGray4)
                                    )
                            )
                    }
                    .disabled(selectedRating < 1 || isSubmitting)
                }
                .padding(.horizontal, 20)
                .padding(.top, 18)
                .padding(.bottom, 20)
            }
            .frame(maxWidth: 330)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(.systemBackground))
            )
        }
        /// 접근성: 모달로 인식
        .accessibilityAddTraits(.isModal)
    }
}

// MARK: - 별점 선택 컴포넌트

struct StarRatingPicker: View {

    // MARK: - Properties

    /// 현재 선택된 별점
    @Binding var selectedRating: Int

    /// 최대 별점(기본 5)
    let maxRating: Int

    // MARK: - Body

    var body: some View {
        HStack(spacing: 10) {
            ForEach(1...maxRating, id: \.self) { index in
                Image(systemName: selectedRating >= index ? "star.fill" : "star")
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(selectedRating >= index ? Color.orange : Color(.systemGray3))
                    .onTapGesture {
                        /// 별점 선택
                        selectedRating = index
                    }
                    .accessibilityLabel("별점 \(index)점")
            }
        }
    }
}
